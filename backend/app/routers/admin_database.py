"""Super Admin: read-only browser over the real SQL tables.

Shows every table exactly as the database stores it: column names and types, primary keys (PK),
foreign keys (FK, with the table.column they point to) and the raw rows. Nothing can be changed here.
"""
from __future__ import annotations

import math
from datetime import date, datetime
from typing import Any

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import Table, func, select
from sqlalchemy.orm import Session

from app import models  # noqa: F401  (registers every table on Base.metadata)
from app.database import Base, get_db
from app.deps import require_permission
from app.models import User

router = APIRouter(prefix="/api/admin/database", tags=["admin: database"])

# Never sent to the browser, whatever the role.
HIDDEN_COLUMNS = {("users", "password_hash")}
HIDDEN_PLACEHOLDER = "(hidden)"
MAX_TEXT = 160  # long text (article HTML, plain text) is cut for the grid


def _tables() -> dict[str, Table]:
    return dict(Base.metadata.tables)


def _type_name(col) -> str:
    try:
        return str(col.type)
    except Exception:  # a type the generic compiler cannot print
        return col.type.__class__.__name__.upper()


def _columns(table: Table) -> list[dict[str, Any]]:
    out = []
    for col in table.columns:
        fk = next(iter(col.foreign_keys), None)
        out.append({
            "name": col.name,
            "type": _type_name(col),
            "primary_key": bool(col.primary_key),
            "foreign_key": fk.target_fullname if fk is not None else None,   # e.g. "users.id"
            "on_delete": (fk.ondelete or None) if fk is not None else None,
            "nullable": bool(col.nullable),
            "unique": bool(col.unique),
            "hidden": (table.name, col.name) in HIDDEN_COLUMNS,
        })
    return out


def _cell(value: Any) -> Any:
    if isinstance(value, (datetime, date)):
        return value.isoformat(sep=" ", timespec="seconds") if isinstance(value, datetime) else value.isoformat()
    if isinstance(value, str) and len(value) > MAX_TEXT:
        return value[:MAX_TEXT] + "…"
    if isinstance(value, (bytes, bytearray)):
        return f"<{len(value)} bytes>"
    return value


@router.get("/tables")
def list_tables(_: User = Depends(require_permission("logs.view")), db: Session = Depends(get_db)):
    """Every table with its row count and column definitions (PK / FK included)."""
    out = []
    for name, table in sorted(_tables().items()):
        columns = _columns(table)
        out.append({
            "name": name,
            "rows": db.scalar(select(func.count()).select_from(table)) or 0,
            "primary_key": [c["name"] for c in columns if c["primary_key"]],
            "foreign_keys": [{"column": c["name"], "references": c["foreign_key"]} for c in columns if c["foreign_key"]],
            "columns": columns,
        })
    return out


@router.get("/tables/{name}")
def table_rows(name: str, page: int = Query(1, ge=1), page_size: int = Query(20, ge=1, le=100),
               newest_first: bool = False, _: User = Depends(require_permission("logs.view")),
               db: Session = Depends(get_db)):
    """Raw rows of one table, ordered by its primary key."""
    table = _tables().get(name)
    if table is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "No such table")
    columns = _columns(table)
    pk_cols = list(table.primary_key.columns)
    order = [c.desc() for c in pk_cols] if newest_first else pk_cols
    total = db.scalar(select(func.count()).select_from(table)) or 0
    stmt = select(table).order_by(*order).offset((page - 1) * page_size).limit(page_size)
    items = []
    for row in db.execute(stmt).mappings().all():
        items.append({c["name"]: HIDDEN_PLACEHOLDER if c["hidden"] else _cell(row[c["name"]]) for c in columns})
    return {"name": name, "columns": columns, "primary_key": [c.name for c in pk_cols], "items": items,
            "total": total, "page": page, "page_size": page_size, "pages": max(1, math.ceil(total / page_size))}
