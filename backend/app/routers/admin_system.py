"""Super Admin: users, roles & permissions, system logs, global settings. Plus the staff dashboard."""
from __future__ import annotations

from datetime import timedelta

from fastapi import APIRouter, Depends, HTTPException, Query, Request, status
from sqlalchemy import desc, func, or_, select
from sqlalchemy.orm import Session

from app import schemas
from app.database import get_db
from app.deps import client_ip, get_current_user, require_permission
from app.models import (AuditLog, Comment, Document, Permission, Report, Role, SearchClickLog, Setting, User,
                        utcnow)
from app.rbac import DEFAULT_SETTINGS, PROTECTED_SUPER_ADMIN_PERMISSIONS
from app.routers.auth import ensure_unique
from app.security import hash_password
from app.utils import audit, get_setting, paginate

router = APIRouter(prefix="/api/admin", tags=["admin: system"])


@router.get("/dashboard")
def dashboard(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    perms = user.permission_codes
    if not perms:
        raise HTTPException(status.HTTP_403_FORBIDDEN, "Staff only")
    week = utcnow() - timedelta(days=7)
    count = lambda stmt: db.scalar(stmt) or 0  # noqa: E731
    out: dict = {"role": user.role.label, "permissions": sorted(perms), "cards": []}
    if perms & {"documents.manage", "documents.publish"}:
        out["cards"] += [
            {"label": "Published articles", "value": count(select(func.count()).select_from(Document).where(Document.status == "published")), "link": "/admin/documents?status=published"},
            {"label": "Drafts", "value": count(select(func.count()).select_from(Document).where(Document.status == "draft")), "link": "/admin/documents?status=draft"},
        ]
    if "comments.moderate" in perms:
        out["cards"].append({"label": "Comments awaiting review", "value": count(select(func.count()).select_from(Comment).where(Comment.status == "pending")), "link": "/admin/comments?status=pending"})
    if "reports.handle" in perms:
        out["cards"].append({"label": "Open reports", "value": count(select(func.count()).select_from(Report).where(Report.status == "open")), "link": "/admin/reports"})
    if "users.manage" in perms:
        out["cards"].append({"label": "Registered users", "value": count(select(func.count()).select_from(User)), "link": "/admin/users"})
    if perms & {"analytics.view", "logs.view"}:
        out["cards"].append({"label": "Searches (last 7 days)", "value": count(select(func.count()).select_from(SearchClickLog).where(SearchClickLog.event_type == "search", SearchClickLog.timestamp >= week)), "link": "/admin/analytics"})
    if "seo.manage" in perms:
        missing = count(select(func.count()).select_from(Document).where(Document.status == "published", ~Document.seo.has()))
        out["cards"].append({"label": "Published articles without SEO metadata", "value": missing, "link": "/admin/seo?missing_only=true"})
    if "logs.view" in perms:
        out["recent_activity"] = [schemas.AuditLogOut.model_validate(a).model_dump(mode="json") for a in
                                  db.execute(select(AuditLog).order_by(desc(AuditLog.id)).limit(8)).unique().scalars()]
    return out


# ------------------------------------------------------------------ users
@router.get("/users", response_model=schemas.Page[schemas.UserAdmin])
def list_users(q: str = "", role: str | None = None, active: bool | None = None, page: int = Query(1, ge=1),
               page_size: int = Query(20, ge=1, le=100), _: User = Depends(require_permission("users.manage")),
               db: Session = Depends(get_db)):
    stmt = select(User).order_by(User.id)
    if q:
        term = f"%{q.lower()}%"
        stmt = stmt.where(or_(func.lower(User.username).like(term), func.lower(User.email).like(term),
                              func.lower(User.full_name).like(term)))
    if role:
        stmt = stmt.join(Role, Role.id == User.role_id).where(Role.name == role)
    if active is not None:
        stmt = stmt.where(User.is_active.is_(active))
    return paginate(db, stmt, page, page_size)


@router.post("/users", response_model=schemas.UserAdmin, status_code=201)
def create_user(body: schemas.UserAdminCreate, request: Request, actor: User = Depends(require_permission("users.manage")),
                db: Session = Depends(get_db)):
    role = db.get(Role, body.role_id)
    if role is None:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "Unknown role")
    ensure_unique(db, body.username, body.email)
    user = User(username=body.username, email=body.email.lower(), password_hash=hash_password(body.password),
                full_name=body.full_name, role=role)
    db.add(user)
    db.flush()
    audit(db, actor.id, "user.create", "user", user.id, f"{user.username} as {role.name}", client_ip(request))
    db.commit()
    return user


def _super_admin_count(db: Session) -> int:
    return db.scalar(select(func.count()).select_from(User).join(Role, Role.id == User.role_id)
                     .where(Role.name == "super_admin", User.is_active.is_(True))) or 0


@router.patch("/users/{user_id}", response_model=schemas.UserAdmin)
def update_user(user_id: int, body: schemas.UserAdminUpdate, request: Request,
                actor: User = Depends(require_permission("users.manage")), db: Session = Depends(get_db)):
    user = db.get(User, user_id)
    if user is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "User not found")
    changes = []
    loses_super = user.role.name == "super_admin" and user.is_active and (
        (body.role_id is not None and body.role_id != user.role_id) or body.is_active is False)
    if loses_super and _super_admin_count(db) <= 1:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "Cannot remove the last active Super Admin")
    if body.role_id is not None and body.role_id != user.role_id:
        role = db.get(Role, body.role_id)
        if role is None:
            raise HTTPException(status.HTTP_400_BAD_REQUEST, "Unknown role")
        changes.append(f"role {user.role.name} -> {role.name}")
        user.role = role
    if body.is_active is not None and body.is_active != user.is_active:
        changes.append("activated" if body.is_active else "deactivated")
        user.is_active = body.is_active
    if body.full_name is not None:
        user.full_name = body.full_name
    if changes:
        audit(db, actor.id, "user.update", "user", user.id, f"{user.username}: {', '.join(changes)}", client_ip(request))
    db.commit()
    db.refresh(user)
    return user


# ------------------------------------------------------------------ roles & permissions
@router.get("/roles", response_model=list[schemas.RoleDetail])
def list_roles(_: User = Depends(require_permission("users.manage", "roles.manage")), db: Session = Depends(get_db)):
    counts = dict(db.execute(select(User.role_id, func.count()).group_by(User.role_id)).all())
    return [schemas.RoleDetail(id=r.id, name=r.name, label=r.label, description=r.description,
                               permissions=sorted(p.code for p in r.permissions), user_count=counts.get(r.id, 0))
            for r in db.execute(select(Role).order_by(Role.id)).scalars()]


@router.get("/permissions", response_model=list[schemas.PermissionOut])
def list_permissions(_: User = Depends(require_permission("roles.manage")), db: Session = Depends(get_db)):
    return db.execute(select(Permission).order_by(Permission.id)).scalars().all()


@router.put("/roles/{role_id}/permissions", response_model=schemas.RoleDetail)
def set_role_permissions(role_id: int, body: schemas.RolePermissionsIn, request: Request,
                         actor: User = Depends(require_permission("roles.manage")), db: Session = Depends(get_db)):
    role = db.get(Role, role_id)
    if role is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Role not found")
    wanted = set(body.permissions)
    if role.name == "super_admin" and not PROTECTED_SUPER_ADMIN_PERMISSIONS <= wanted:
        raise HTTPException(status.HTTP_400_BAD_REQUEST,
                            "Super Admin must keep users.manage and roles.manage (prevents lock-out)")
    perms = db.execute(select(Permission).where(Permission.code.in_(wanted))).scalars().all()
    unknown = wanted - {p.code for p in perms}
    if unknown:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, f"Unknown permission(s): {', '.join(sorted(unknown))}")
    before = sorted(p.code for p in role.permissions)
    role.permissions = list(perms)
    audit(db, actor.id, "role.permissions", "role", role.id,
          f"{role.name}: {before} -> {sorted(wanted)}", client_ip(request))
    db.commit()
    count = db.scalar(select(func.count()).select_from(User).where(User.role_id == role.id)) or 0
    return schemas.RoleDetail(id=role.id, name=role.name, label=role.label, description=role.description,
                              permissions=sorted(wanted), user_count=count)


# ------------------------------------------------------------------ logs
@router.get("/audit-logs", response_model=schemas.Page[schemas.AuditLogOut])
def audit_logs(action: str | None = None, q: str = "", page: int = Query(1, ge=1),
               page_size: int = Query(30, ge=1, le=200), _: User = Depends(require_permission("logs.view")),
               db: Session = Depends(get_db)):
    stmt = select(AuditLog).order_by(desc(AuditLog.id))
    if action:
        stmt = stmt.where(AuditLog.action.like(f"{action}%"))
    if q:
        stmt = stmt.where(AuditLog.detail.ilike(f"%{q}%"))
    return paginate(db, stmt, page, page_size)


@router.get("/search-logs", response_model=schemas.Page[schemas.SearchLogOut])
def search_logs(event_type: str | None = Query(None, pattern="^(search|click)$"), q: str = "",
                page: int = Query(1, ge=1), page_size: int = Query(50, ge=1, le=500),
                _: User = Depends(require_permission("logs.view", "analytics.view")), db: Session = Depends(get_db)):
    stmt = select(SearchClickLog).order_by(desc(SearchClickLog.id))
    if event_type:
        stmt = stmt.where(SearchClickLog.event_type == event_type)
    if q:
        stmt = stmt.where(SearchClickLog.query_string.ilike(f"%{q}%"))
    return paginate(db, stmt, page, page_size)


# ------------------------------------------------------------------ settings
@router.get("/settings")
def get_settings(_: User = Depends(require_permission("settings.manage")), db: Session = Depends(get_db)):
    return {key: get_setting(db, key) for key in DEFAULT_SETTINGS}


@router.put("/settings")
def put_settings(body: dict[str, str], request: Request, actor: User = Depends(require_permission("settings.manage")),
                 db: Session = Depends(get_db)):
    unknown = set(body) - set(DEFAULT_SETTINGS)
    if unknown:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, f"Unknown setting(s): {', '.join(sorted(unknown))}")
    for key in ("page_size", "max_links_per_comment", "comment_rate_limit_per_minute"):
        if key in body and not body[key].strip().isdigit():
            raise HTTPException(status.HTTP_400_BAD_REQUEST, f"{key} must be a whole number")
    changed = []
    for key, value in body.items():
        row = db.get(Setting, key)
        if row is None:
            db.add(Setting(key=key, value=value))
            changed.append(key)
        elif row.value != value:
            row.value = value
            changed.append(key)
    if changed:
        audit(db, actor.id, "settings.update", "settings", "", ", ".join(changed), client_ip(request))
    db.commit()
    return {key: get_setting(db, key) for key in DEFAULT_SETTINGS}
