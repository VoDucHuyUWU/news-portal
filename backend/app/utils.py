"""Shared helpers: slugs, HTML sanitising, plain-text extraction, pagination, settings, audit log."""
from __future__ import annotations

import html
import math
import re
import unicodedata
from typing import Any

import nh3
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.models import AuditLog, Setting
from app.rbac import DEFAULT_SETTINGS

ALLOWED_TAGS = {"p", "h2", "h3", "h4", "strong", "em", "b", "i", "u", "ul", "ol", "li", "blockquote",
                "a", "img", "figure", "figcaption", "br", "hr", "code", "pre", "span"}
ALLOWED_ATTRIBUTES = {"a": {"href", "title"}, "img": {"src", "alt", "title", "width", "height"}}
MENTION_RE = re.compile(r"(?<![\w@])@([A-Za-z0-9_]{3,40})")


def slugify(text: str, max_length: int = 80) -> str:
    text = unicodedata.normalize("NFKD", text).encode("ascii", "ignore").decode("ascii")
    text = re.sub(r"[^a-zA-Z0-9]+", "-", text.lower()).strip("-")
    return text[:max_length].strip("-") or "item"


def unique_slug(db: Session, model, base: str, exclude_id: int | None = None) -> str:
    slug, n = slugify(base), 2
    while True:
        stmt = select(model.id).where(model.slug == slug)
        found = db.execute(stmt).scalar_one_or_none()
        if found is None or found == exclude_id:
            return slug
        slug = f"{slugify(base)}-{n}"
        n += 1


def sanitize_html(raw: str) -> str:
    """Remove scripts, event handlers and unknown tags (prevents stored XSS)."""
    return nh3.clean(raw, tags=ALLOWED_TAGS, attributes=ALLOWED_ATTRIBUTES, link_rel="noopener noreferrer")


def html_to_text(raw: str) -> str:
    """Plain text used by search now and by the Phase-2 tokenizer later."""
    text = re.sub(r"<\s*(br|/p|/h[1-6]|/li|/blockquote)\s*/?>", "\n", raw, flags=re.I)
    text = re.sub(r"<[^>]+>", " ", text)
    text = html.unescape(text)
    text = re.sub(r"[ \t]+", " ", text)
    return re.sub(r"\s*\n\s*", "\n", text).strip()


def make_summary(text: str, length: int = 220) -> str:
    text = " ".join(text.split())
    if len(text) <= length:
        return text
    return text[:length].rsplit(" ", 1)[0].rstrip(",.;:") + "…"


def paginate(db: Session, stmt, page: int, page_size: int) -> dict[str, Any]:
    total = db.execute(select(func.count()).select_from(stmt.order_by(None).subquery())).scalar_one()
    items = db.execute(stmt.offset((page - 1) * page_size).limit(page_size)).unique().scalars().all()
    return {"items": items, "total": total, "page": page, "page_size": page_size,
            "pages": max(1, math.ceil(total / page_size))}


def get_setting(db: Session, key: str) -> str:
    row = db.get(Setting, key)
    return row.value if row is not None else DEFAULT_SETTINGS.get(key, "")


def get_bool_setting(db: Session, key: str) -> bool:
    return get_setting(db, key).strip().lower() in ("1", "true", "yes", "on")


def get_int_setting(db: Session, key: str, default: int) -> int:
    try:
        return int(get_setting(db, key))
    except ValueError:
        return default


def audit(db: Session, actor_id: int | None, action: str, entity: str = "", entity_id: Any = "",
          detail: str = "", ip: str = "") -> None:
    db.add(AuditLog(actor_id=actor_id, action=action, entity=entity, entity_id=str(entity_id),
                    detail=detail[:2000], ip_address=ip))


def escape_like(term: str) -> str:
    return term.replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_")
