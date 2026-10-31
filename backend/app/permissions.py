"""
Role-Based Access Control catalogue.

Access is checked by PERMISSION code (never by role name), so a Super Admin can
re-assign permissions between roles at runtime without code changes.
"""
from __future__ import annotations

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models import Permission, Role

PERMISSIONS: dict[str, str] = {
    # Super Admin
    "user.manage": "Create users, change roles, activate/deactivate accounts",
    "role.manage": "Assign permissions to roles",
    "log.view": "View system (audit) logs and raw search/click logs",
    "settings.manage": "Configure global site settings",
    # Content Manager
    "document.create": "Create documents",
    "document.update": "Edit any document",
    "document.delete": "Delete documents",
    "document.publish": "Publish / unpublish documents",
    "taxonomy.manage": "Create, edit and delete categories and tags",
    "media.upload": "Upload images",
    # Moderator
    "comment.moderate": "Review, hide, approve or delete comments",
    "report.handle": "Handle user flags/reports",
    "spam.manage": "Manage spam keywords and mute users",
    # Data & SEO Specialist
    "seo.manage": "Edit SEO metadata (titles, descriptions, keywords, alt text)",
    "analytics.view": "View analytics dashboards",
}

ROLES: dict[str, dict] = {
    "super_admin": {"label": "Super Admin", "description": "Full control of users, roles, logs and settings",
                    "permissions": list(PERMISSIONS)},
    "content_manager": {"label": "Content Manager", "description": "Content CRUD, publishing and taxonomy",
                        "permissions": ["document.create", "document.update", "document.delete",
                                        "document.publish", "taxonomy.manage", "media.upload"]},
    "moderator": {"label": "Moderator", "description": "Comments, reports and spam control",
                  "permissions": ["comment.moderate", "report.handle", "spam.manage"]},
    "seo_specialist": {"label": "Data & SEO Specialist", "description": "SEO metadata and analytics",
                       "permissions": ["seo.manage", "analytics.view"]},
    "user": {"label": "Reader", "description": "Registered reader: comment, like, rate, tag users",
             "permissions": []},
}
DEFAULT_ROLE = "user"
# Permissions that must never be removed from super_admin (prevents locking everyone out).
PROTECTED_SUPER_ADMIN_PERMISSIONS = {"user.manage", "role.manage"}
# Any of these grants access to the admin console.
ADMIN_CONSOLE_PERMISSIONS = set(PERMISSIONS)


def ensure_rbac(db: Session) -> None:
    """Create missing permissions and roles. Existing role assignments are kept (idempotent)."""
    existing = {p.code: p for p in db.scalars(select(Permission))}
    for code, description in PERMISSIONS.items():
        if code not in existing:
            existing[code] = Permission(code=code, description=description)
            db.add(existing[code])
    db.flush()
    for name, spec in ROLES.items():
        role = db.scalar(select(Role).where(Role.name == name))
        if role is None:
            role = Role(name=name, label=spec["label"], description=spec["description"])
            role.permissions = [existing[c] for c in spec["permissions"]]
            db.add(role)
        elif name == "super_admin":  # super admin always holds every permission
            have = role.permission_codes
            role.permissions += [existing[c] for c in PERMISSIONS if c not in have]
    db.commit()
