"""Profile management, public profiles, mention look-up."""
from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import func, or_, select
from sqlalchemy.orm import Session

from app import schemas
from app.database import get_db
from app.deps import get_current_user
from app.models import Comment, CommentMention, Document, User
from app.routers.auth import ensure_unique
from app.security import hash_password, verify_password
from app.services import comments_out, user_me

router = APIRouter(prefix="/api/users", tags=["users"])


@router.patch("/me", response_model=schemas.UserMe)
def update_profile(body: schemas.ProfileUpdate, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    data = body.model_dump(exclude_unset=True)
    if "email" in data and data["email"]:
        ensure_unique(db, user.username, data["email"], exclude_id=user.id)
        user.email = data["email"].lower()
    for field in ("full_name", "bio", "avatar_url"):
        if field in data:
            setattr(user, field, (data[field] or "").strip() if field != "avatar_url" else (data[field] or None))
    db.commit()
    return user_me(user)


@router.post("/me/password", status_code=204)
def change_password(body: schemas.PasswordChange, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    if not verify_password(body.current_password, user.password_hash):
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "Current password is incorrect")
    user.password_hash = hash_password(body.new_password)
    db.commit()


@router.get("/me/mentions", response_model=list[schemas.MentionOut])
def my_mentions(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    rows = db.execute(select(Comment).join(CommentMention, CommentMention.comment_id == Comment.id)
                      .where(CommentMention.mentioned_user_id == user.id, Comment.status == "visible")
                      .order_by(Comment.created_at.desc()).limit(50)).unique().scalars().all()
    return [schemas.MentionOut(comment_id=c.id, content=c.content, created_at=c.created_at,
                               by=schemas.UserPublic.model_validate(c.user), document_title=c.document.title,
                               document_slug=c.document.slug) for c in rows]


@router.get("/lookup", response_model=list[schemas.UserPublic])
def lookup(q: str = Query(min_length=1, max_length=40), db: Session = Depends(get_db)):
    """Autocomplete for @mentions."""
    term = f"{q.lower()}%"
    return db.execute(select(User).where(User.is_active.is_(True),
                                         or_(func.lower(User.username).like(term), func.lower(User.full_name).like(term)))
                      .order_by(User.username).limit(8)).scalars().all()


@router.get("/{username}")
def public_profile(username: str, db: Session = Depends(get_db)):
    user = db.execute(select(User).where(func.lower(User.username) == username.lower(),
                                         User.is_active.is_(True))).scalar_one_or_none()
    if user is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "User not found")
    recent = db.execute(select(Comment).join(Document, Document.id == Comment.document_id)
                        .where(Comment.user_id == user.id, Comment.status == "visible", Document.status == "published")
                        .order_by(Comment.created_at.desc()).limit(10)).unique().scalars().all()
    articles = db.execute(select(Document).where(Document.author_id == user.id, Document.status == "published")
                          .order_by(Document.published_at.desc()).limit(6)).unique().scalars().all()
    comment_total = db.scalar(select(func.count()).select_from(Comment)
                              .where(Comment.user_id == user.id, Comment.status == "visible")) or 0
    return {
        "user": schemas.UserPublic.model_validate(user).model_dump(),
        "role": user.role.label, "joined": user.created_at.isoformat() + "Z", "comment_count": comment_total,
        "recent_comments": [{**c.model_dump(mode="json"), "document_title": d.document.title,
                             "document_slug": d.document.slug} for c, d in zip(comments_out(db, recent), recent)],
        "articles": [schemas.DocumentCard.model_validate(a).model_dump(mode="json") for a in articles],
    }
