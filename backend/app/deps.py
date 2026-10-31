"""FastAPI dependencies: database session, current user, permission checks."""
from __future__ import annotations

from collections.abc import Callable

from fastapi import Depends, HTTPException, Request, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import User
from app.security import decode_access_token


def _token_from(request: Request) -> str | None:
    header = request.headers.get("Authorization", "")
    if header.lower().startswith("bearer "):
        return header[7:].strip() or None
    return None


def get_current_user_optional(request: Request, db: Session = Depends(get_db)) -> User | None:
    token = _token_from(request)
    if not token:
        return None
    user_id = decode_access_token(token)
    if user_id is None:
        return None
    user = db.get(User, user_id)
    return user if user and user.is_active else None


def get_current_user(request: Request, db: Session = Depends(get_db)) -> User:
    token = _token_from(request)
    if not token:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Please log in.",
                            headers={"WWW-Authenticate": "Bearer"})
    user_id = decode_access_token(token)
    user = db.get(User, user_id) if user_id is not None else None
    if user is None:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Session expired. Please log in again.",
                            headers={"WWW-Authenticate": "Bearer"})
    if not user.is_active:
        raise HTTPException(status.HTTP_403_FORBIDDEN, "This account has been deactivated.")
    return user


def require_permission(*codes: str) -> Callable[..., User]:
    """Dependency factory: the current user must hold AT LEAST ONE of ``codes``."""
    def checker(user: User = Depends(get_current_user)) -> User:
        if not user.can(*codes):
            raise HTTPException(status.HTTP_403_FORBIDDEN,
                                f"Your role ({user.role.label}) is not allowed to do this. "
                                f"Required permission: {' or '.join(codes)}.")
        return user
    return checker


def client_ip(request: Request) -> str:
    return request.client.host if request.client else ""
