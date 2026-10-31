"""Registration, login and the current user."""
from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, Request, status
from sqlalchemy import func, or_, select
from sqlalchemy.orm import Session

from app import schemas
from app.database import get_db, utcnow
from app.deps import get_current_user
from app.models import Role, User
from app.permissions import DEFAULT_ROLE
from app.security import create_access_token, hash_password, verify_password
from app.serializers import me_out
from app.services import audit, get_setting

router = APIRouter(prefix="/api/auth", tags=["auth"])


def create_user(db: Session, data: schemas.RegisterIn, role_name: str = DEFAULT_ROLE) -> User:
    if db.scalar(select(User).where(func.lower(User.username) == data.username.lower())):
        raise HTTPException(status.HTTP_409_CONFLICT, "This username is already taken.")
    if db.scalar(select(User).where(func.lower(User.email) == str(data.email).lower())):
        raise HTTPException(status.HTTP_409_CONFLICT, "An account with this email already exists.")
    role = db.scalar(select(Role).where(Role.name == role_name))
    if role is None:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, f"Unknown role {role_name!r}.")
    user = User(username=data.username.lower(), email=str(data.email).lower(),
                password_hash=hash_password(data.password), full_name=data.full_name.strip(), role=role)
    db.add(user)
    db.flush()
    return user


@router.post("/register", response_model=schemas.TokenOut, status_code=201)
def register(data: schemas.RegisterIn, request: Request, db: Session = Depends(get_db)):
    if not get_setting(db, "allow_registration"):
        raise HTTPException(status.HTTP_403_FORBIDDEN, "Registration is currently closed.")
    user = create_user(db, data)
    audit(db, user, "user.register", "user", user.id, f"New reader @{user.username}", request)
    db.refresh(user)
    return schemas.TokenOut(access_token=create_access_token(user.id, user.role.name), user=me_out(user))


@router.post("/login", response_model=schemas.TokenOut)
def login(data: schemas.LoginIn, request: Request, db: Session = Depends(get_db)):
    ident = data.username.strip().lower()
    user = db.scalar(select(User).where(or_(func.lower(User.username) == ident, func.lower(User.email) == ident)))
    if user is None or not verify_password(data.password, user.password_hash):
        audit(db, user, "auth.login_failed", "user", user.id if user else "", f"identifier={ident}", request)
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Wrong username/email or password.")
    if not user.is_active:
        raise HTTPException(status.HTTP_403_FORBIDDEN, "This account has been deactivated.")
    user.last_login_at = utcnow()
    audit(db, user, "auth.login", "user", user.id, "", request)
    return schemas.TokenOut(access_token=create_access_token(user.id, user.role.name), user=me_out(user))


@router.get("/me", response_model=schemas.MeOut)
def me(user: User = Depends(get_current_user)):
    return me_out(user)
