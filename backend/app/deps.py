"""FastAPI dependencies: current user and permission checks (RBAC is enforced server-side)."""
from __future__ import annotations

from fastapi import Depends, HTTPException, Request, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import User
from app.security import decode_access_token

bearer = HTTPBearer(auto_error=False)


def get_optional_user(creds: HTTPAuthorizationCredentials | None = Depends(bearer),
                      db: Session = Depends(get_db)) -> User | None:
    if creds is None:
        return None
    user_id = decode_access_token(creds.credentials)
    if user_id is None:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Invalid or expired token")
    user = db.get(User, user_id)
    if user is None or not user.is_active:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Account not found or deactivated")
    return user


def get_current_user(user: User | None = Depends(get_optional_user)) -> User:
    if user is None:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Login required",
                            headers={"WWW-Authenticate": "Bearer"})
    return user


def require_permission(*codes: str):
    """Allow the request if the user's role holds ANY of the given permission codes."""

    def checker(user: User = Depends(get_current_user)) -> User:
        if not set(codes) & user.permission_codes:
            raise HTTPException(status.HTTP_403_FORBIDDEN,
                                f"Missing permission: {' or '.join(codes)}")
        return user

    return checker


def client_ip(request: Request) -> str:
    return request.client.host if request.client else ""
