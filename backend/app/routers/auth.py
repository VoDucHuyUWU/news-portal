"""Registration, login and the current user."""
from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, Request, status
from sqlalchemy import func, or_, select
from sqlalchemy.orm import Session

from app import schemas
from app.database import get_db
from app.deps import client_ip, get_current_user
from app.models import Role, User, utcnow
from app.rbac import DEFAULT_ROLE
from app.security import create_access_token, hash_password, verify_password
from app.services import user_me
from app.utils import audit, get_bool_setting

router = APIRouter(prefix="/api/auth", tags=["auth"])


def _token_response(user: User) -> schemas.TokenOut:
    return schemas.TokenOut(access_token=create_access_token(user.id, user.role.name), user=user_me(user))


def ensure_unique(db: Session, username: str, email: str, exclude_id: int | None = None) -> None:
    clash = db.execute(select(User).where(or_(func.lower(User.username) == username.lower(),
                                              func.lower(User.email) == email.lower()))).scalars().all()
    for u in clash:
        if u.id == exclude_id:
            continue
        field = "Username" if u.username.lower() == username.lower() else "Email"
        raise HTTPException(status.HTTP_409_CONFLICT, f"{field} is already taken")


@router.post("/register", response_model=schemas.TokenOut, status_code=201)
def register(body: schemas.RegisterIn, request: Request, db: Session = Depends(get_db)):
    if not get_bool_setting(db, "allow_registration"):
        raise HTTPException(status.HTTP_403_FORBIDDEN, "Registration is currently closed")
    ensure_unique(db, body.username, body.email)
    role = db.execute(select(Role).where(Role.name == DEFAULT_ROLE)).scalar_one()
    user = User(username=body.username, email=body.email.lower(), password_hash=hash_password(body.password),
                full_name=body.full_name.strip(), role=role, last_login_at=utcnow())
    db.add(user)
    db.flush()
    audit(db, user.id, "auth.register", "user", user.id, ip=client_ip(request))
    db.commit()
    return _token_response(user)


@router.post("/login", response_model=schemas.TokenOut)
def login(body: schemas.LoginIn, request: Request, db: Session = Depends(get_db)):
    ident = body.login.strip().lower()
    user = db.execute(select(User).where(or_(func.lower(User.username) == ident,
                                             func.lower(User.email) == ident))).scalar_one_or_none()
    if user is None or not verify_password(body.password, user.password_hash):
        audit(db, user.id if user else None, "auth.login_failed", "user", user.id if user else "",
              detail=f"login={body.login[:80]}", ip=client_ip(request))
        db.commit()
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Incorrect username/email or password")
    if not user.is_active:
        raise HTTPException(status.HTTP_403_FORBIDDEN, "This account has been deactivated")
    user.last_login_at = utcnow()
    audit(db, user.id, "auth.login", "user", user.id, ip=client_ip(request))
    db.commit()
    return _token_response(user)


@router.get("/me", response_model=schemas.UserMe)
def me(user: User = Depends(get_current_user)):
    return user_me(user)
