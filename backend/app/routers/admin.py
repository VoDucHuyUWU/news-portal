"""Super Admin: users, roles & permissions, system logs, global settings."""
from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, Query, Request, status
from sqlalchemy import func, or_, select
from sqlalchemy.orm import Session

from app import schemas
from app.config import MAX_PAGE_SIZE
from app.database import get_db
from app.deps import get_current_user, require_permission
from app.models import AuditLog, Permission, Role, SearchClickLog, User
from app.permissions import ADMIN_CONSOLE_PERMISSIONS, PROTECTED_SUPER_ADMIN_PERMISSIONS
from app.routers.auth import create_user
from app.serializers import paginate, user_out
from app.services import PUBLIC_SETTINGS, SUPER_ADMIN_SETTINGS, audit, get_setting, set_setting

router = APIRouter(tags=["admin"])


def _super_admin_count(db: Session) -> int:
    return db.scalar(select(func.count()).select_from(User).join(Role)
                     .where(Role.name == "super_admin", User.is_active.is_(True))) or 0


# --------------------------------------------------------------------- users
@router.get("/api/admin/users", response_model=schemas.Page)
def list_users(q: str | None = None, role: str | None = None, page: int = Query(1, ge=1),
               page_size: int = Query(20, ge=1, le=MAX_PAGE_SIZE),
               _: User = Depends(require_permission("user.manage", "spam.manage")), db: Session = Depends(get_db)):
    query = select(User).join(Role)
    if q:
        query = query.where(or_(User.username.ilike(f"%{q}%"), User.email.ilike(f"%{q}%"),
                                User.full_name.ilike(f"%{q}%")))
    if role:
        query = query.where(Role.name == role)
    total = db.scalar(select(func.count()).select_from(query.subquery())) or 0
    rows = db.scalars(query.order_by(User.created_at.desc(), User.id.desc())
                      .offset((page - 1) * page_size).limit(page_size)).unique().all()
    return paginate(total, page, page_size, [user_out(u) for u in rows])


@router.post("/api/admin/users", response_model=schemas.UserOut, status_code=201)
def create_user_admin(data: schemas.AdminUserCreate, request: Request,
                      actor: User = Depends(require_permission("user.manage")), db: Session = Depends(get_db)):
    user = create_user(db, data, data.role)
    audit(db, actor, "user.create", "user", user.id, f"@{user.username} as {data.role}", request)
    db.refresh(user)
    return user_out(user)


@router.put("/api/admin/users/{user_id}", response_model=schemas.UserOut)
def update_user_admin(user_id: int, data: schemas.AdminUserUpdate, request: Request,
                      actor: User = Depends(require_permission("user.manage")), db: Session = Depends(get_db)):
    user = db.get(User, user_id)
    if user is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "User not found.")
    changes = []
    leaving_super_admin = user.role.name == "super_admin" and (
        (data.role is not None and data.role != "super_admin") or data.is_active is False)
    if leaving_super_admin and _super_admin_count(db) <= 1:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "There must be at least one active Super Admin.")
    if user.id == actor.id and data.is_active is False:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "You cannot deactivate your own account.")
    if data.role is not None and data.role != user.role.name:
        role = db.scalar(select(Role).where(Role.name == data.role))
        if role is None:
            raise HTTPException(status.HTTP_400_BAD_REQUEST, "Unknown role.")
        changes.append(f"role {user.role.name} -> {role.name}")
        user.role = role
    for field in ("is_active", "is_muted", "full_name"):
        value = getattr(data, field)
        if value is not None and value != getattr(user, field):
            changes.append(f"{field}={value}")
            setattr(user, field, value)
    audit(db, actor, "user.update", "user", user.id, f"@{user.username}: " + "; ".join(changes), request)
    db.refresh(user)
    return user_out(user)


# --------------------------------------------------------- roles/permissions
@router.get("/api/admin/roles")
def list_roles(_: User = Depends(require_permission("role.manage", "user.manage")), db: Session = Depends(get_db)):
    counts = dict(db.execute(select(User.role_id, func.count()).group_by(User.role_id)).all())
    return {
        "permissions": [{"code": p.code, "description": p.description}
                        for p in db.scalars(select(Permission).order_by(Permission.id))],
        "roles": [{"name": r.name, "label": r.label, "description": r.description,
                   "permissions": sorted(r.permission_codes), "user_count": counts.get(r.id, 0)}
                  for r in db.scalars(select(Role).order_by(Role.id))],
        "protected": {"super_admin": sorted(PROTECTED_SUPER_ADMIN_PERMISSIONS)},
    }


@router.put("/api/admin/roles/{role_name}/permissions")
def set_role_permissions(role_name: str, data: schemas.RolePermissionsIn, request: Request,
                         actor: User = Depends(require_permission("role.manage")), db: Session = Depends(get_db)):
    role = db.scalar(select(Role).where(Role.name == role_name))
    if role is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Role not found.")
    wanted = set(data.permissions)
    perms = db.scalars(select(Permission).where(Permission.code.in_(wanted))).all()
    unknown = wanted - {p.code for p in perms}
    if unknown:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, f"Unknown permissions: {sorted(unknown)}")
    if role.name == "super_admin" and not PROTECTED_SUPER_ADMIN_PERMISSIONS <= wanted:
        raise HTTPException(status.HTTP_400_BAD_REQUEST,
                            "Super Admin must keep user.manage and role.manage (prevents lock-out).")
    before = role.permission_codes
    role.permissions = list(perms)
    added, removed = sorted(wanted - before), sorted(before - wanted)
    audit(db, actor, "role.permissions_update", "role", role.name, f"added={added} removed={removed}", request)
    return {"name": role.name, "permissions": sorted(role.permission_codes)}


# ---------------------------------------------------------------------- logs
@router.get("/api/admin/logs", response_model=schemas.Page)
def audit_logs(action: str | None = None, actor: str | None = None, page: int = Query(1, ge=1),
               page_size: int = Query(30, ge=1, le=MAX_PAGE_SIZE),
               _: User = Depends(require_permission("log.view")), db: Session = Depends(get_db)):
    query = select(AuditLog)
    if action:
        query = query.where(AuditLog.action.ilike(f"{action}%"))
    if actor:
        query = query.join(User, AuditLog.actor_id == User.id).where(User.username.ilike(f"%{actor}%"))
    total = db.scalar(select(func.count()).select_from(query.subquery())) or 0
    rows = db.scalars(query.order_by(AuditLog.timestamp.desc(), AuditLog.id.desc())
                      .offset((page - 1) * page_size).limit(page_size)).unique().all()
    return paginate(total, page, page_size, [schemas.AuditOut.model_validate(r) for r in rows])


@router.get("/api/admin/search-logs", response_model=schemas.Page)
def search_logs(event_type: str | None = None, source: str | None = None, q: str | None = None,
                page: int = Query(1, ge=1), page_size: int = Query(30, ge=1, le=MAX_PAGE_SIZE),
                _: User = Depends(require_permission("log.view", "analytics.view")), db: Session = Depends(get_db)):
    """Raw rows of the search & click log table (the Phase 2 training/evaluation data)."""
    query = select(SearchClickLog)
    if event_type:
        query = query.where(SearchClickLog.event_type == event_type)
    if source:
        query = query.where(SearchClickLog.source == source)
    if q:
        query = query.where(SearchClickLog.query_string.ilike(f"%{q}%"))
    total = db.scalar(select(func.count()).select_from(query.subquery())) or 0
    rows = db.scalars(query.order_by(SearchClickLog.timestamp.desc(), SearchClickLog.id.desc())
                      .offset((page - 1) * page_size).limit(page_size)).all()
    return paginate(total, page, page_size, [schemas.SearchLogOut.model_validate(r) for r in rows])


# ------------------------------------------------------------------ settings
@router.get("/api/settings", tags=["system"])
def public_settings(db: Session = Depends(get_db)):
    return {key: get_setting(db, key) for key in PUBLIC_SETTINGS}


@router.get("/api/admin/settings")
def admin_settings(_: User = Depends(require_permission("settings.manage")), db: Session = Depends(get_db)):
    return {key: get_setting(db, key) for key in SUPER_ADMIN_SETTINGS}


@router.put("/api/admin/settings")
def update_settings(data: schemas.SettingsIn, request: Request,
                    actor: User = Depends(require_permission("settings.manage")), db: Session = Depends(get_db)):
    changes = data.model_dump(exclude_unset=True, exclude_none=True)
    for key, value in changes.items():
        set_setting(db, key, value.strip() if isinstance(value, str) else value, actor)
    audit(db, actor, "settings.update", "setting", "", ", ".join(f"{k}={v}" for k, v in changes.items()), request)
    return {key: get_setting(db, key) for key in SUPER_ADMIN_SETTINGS}


@router.get("/api/admin/me")
def admin_access(user: User = Depends(get_current_user)):
    """Which admin sections the current user may open (the UI builds its menu from this)."""
    perms = user.permissions
    return {"can_access_admin": bool(perms & ADMIN_CONSOLE_PERMISSIONS), "role": user.role.name,
            "role_label": user.role.label, "permissions": sorted(perms)}
