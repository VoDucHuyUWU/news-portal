"""Idempotent reference data: roles, permissions and default settings (created on every start-up)."""
from __future__ import annotations

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models import Permission, Role, Setting
from app.rbac import DEFAULT_SETTINGS, PERMISSIONS, ROLES


def ensure_reference_data(db: Session) -> None:
    perms = {p.code: p for p in db.execute(select(Permission)).scalars()}
    for code, description in PERMISSIONS.items():
        if code not in perms:
            perms[code] = Permission(code=code, description=description)
            db.add(perms[code])
    existing_roles = {r.name for r in db.execute(select(Role)).scalars()}
    for name, spec in ROLES.items():
        if name not in existing_roles:  # never overwrite permissions an admin has customised
            db.add(Role(name=name, label=spec["label"], description=spec["description"],
                        permissions=[perms[c] for c in spec["permissions"]]))
    for key, value in DEFAULT_SETTINGS.items():
        if db.get(Setting, key) is None:
            db.add(Setting(key=key, value=value))
    db.commit()
