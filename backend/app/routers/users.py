"""Profile management, public profiles, mention lookup."""
from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, Query, Request, status
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app import schemas
from app.database import get_db
from app.deps import get_current_user
from app.models import Comment, CommentMention, User
from app.security import hash_password, verify_password
from app.serializers import comment_admin_out, me_out
from app.services import audit

router = APIRouter(prefix="/api/users", tags=["users"])


@router.get("/me", response_model=schemas.MeOut)
def get_me(user: User = Depends(get_current_user)):
    return me_out(user)


@router.put("/me", response_model=schemas.MeOut)
def update_me(data: schemas.ProfileUpdate, request: Request, user: User = Depends(get_current_user),
              db: Session = Depends(get_db)):
    changes = data.model_dump(exclude_unset=True)
    if "email" in changes and changes["email"]:
        email = str(changes["email"]).lower()
        clash = db.scalar(select(User).where(func.lower(User.email) == email, User.id != user.id))
        if clash:
            raise HTTPException(status.HTTP_409_CONFLICT, "An account with this email already exists.")
        user.email = email
    for field in ("full_name", "bio", "avatar_url"):
        if field in changes and changes[field] is not None:
            setattr(user, field, changes[field].strip())
    audit(db, user, "user.profile_update", "user", user.id, ", ".join(sorted(changes)), request)
    return me_out(user)


@router.post("/me/password", status_code=204)
def change_password(data: schemas.PasswordChange, request: Request, user: User = Depends(get_current_user),
                    db: Session = Depends(get_db)):
    if not verify_password(data.current_password, user.password_hash):
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "Current password is incorrect.")
    user.password_hash = hash_password(data.new_password)
    audit(db, user, "user.password_change", "user", user.id, "", request)


@router.get("/me/mentions", response_model=list[schemas.CommentAdminOut])
def my_mentions(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    """Comments in which the current user was tagged with @username."""
    comments = db.scalars(
        select(Comment).join(CommentMention, CommentMention.comment_id == Comment.id)
        .where(CommentMention.user_id == user.id, Comment.status == "visible")
        .order_by(Comment.created_at.desc()).limit(30)).all()
    return [comment_admin_out(c) for c in comments]


@router.get("/lookup", response_model=list[schemas.UserBrief])
def lookup(q: str = Query(min_length=1, max_length=40), _: User = Depends(get_current_user),
           db: Session = Depends(get_db)):
    """Username autocomplete for @mentions."""
    rows = db.scalars(select(User).where(User.is_active.is_(True), User.username.ilike(f"{q.lower()}%"))
                      .order_by(User.username).limit(8)).all()
    return [schemas.UserBrief.model_validate(u) for u in rows]


@router.get("/{username}", response_model=schemas.PublicProfile)
def public_profile(username: str, db: Session = Depends(get_db)):
    user = db.scalar(select(User).where(func.lower(User.username) == username.lower()))
    if user is None or not user.is_active:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "User not found.")
    visible = select(Comment).where(Comment.user_id == user.id, Comment.status == "visible")
    count = db.scalar(select(func.count()).select_from(visible.subquery())) or 0
    recent = db.scalars(visible.order_by(Comment.created_at.desc()).limit(10)).all()
    return schemas.PublicProfile(
        id=user.id, username=user.username, full_name=user.full_name, avatar_url=user.avatar_url, bio=user.bio,
        role_label=user.role.label, created_at=user.created_at, comment_count=count,
        recent_comments=[{"id": c.id, "content": c.content, "document_title": c.document.title,
                          "document_slug": c.document.slug, "created_at": c.created_at.isoformat() + "Z"}
                         for c in recent])
