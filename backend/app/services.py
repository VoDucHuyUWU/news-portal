"""Shared helpers: slugs, HTML sanitising, audit logging, settings, mentions, spam checks."""
from __future__ import annotations

import html
import re
import unicodedata
from html.parser import HTMLParser
from typing import Any

import nh3
from fastapi import Request
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.deps import client_ip
from app.models import AuditLog, Setting, User

# ------------------------------------------------------------------ text utils
def slugify(text: str, max_length: int = 120) -> str:
    text = unicodedata.normalize("NFKD", text).encode("ascii", "ignore").decode()
    text = re.sub(r"[^a-zA-Z0-9]+", "-", text).strip("-").lower()
    return text[:max_length].strip("-") or "item"


def unique_slug(db: Session, model, base: str, exclude_id: int | None = None) -> str:
    slug, n = slugify(base), 2
    candidate = slug
    while True:
        existing = db.scalar(select(model).where(model.slug == candidate))
        if existing is None or existing.id == exclude_id:
            return candidate
        candidate, n = f"{slug}-{n}", n + 1


ALLOWED_TAGS = {"p", "br", "h2", "h3", "h4", "strong", "b", "em", "i", "u", "ul", "ol", "li", "blockquote",
                "a", "img", "figure", "figcaption", "code", "pre", "hr", "table", "thead", "tbody", "tr",
                "th", "td"}
ALLOWED_ATTRIBUTES = {"a": {"href", "title"}, "img": {"src", "alt", "title", "width", "height"}}


def sanitize_html(content: str) -> str:
    """Allow a safe subset of HTML (no scripts, no event handlers, no inline styles)."""
    return nh3.clean(content or "", tags=ALLOWED_TAGS, attributes=ALLOWED_ATTRIBUTES,
                     url_schemes={"http", "https", "mailto"}, link_rel="noopener noreferrer")


class _TextExtractor(HTMLParser):
    BLOCK = {"p", "br", "h1", "h2", "h3", "h4", "li", "blockquote", "tr", "pre", "figcaption", "div"}

    def __init__(self) -> None:
        super().__init__()
        self.parts: list[str] = []

    def handle_starttag(self, tag, attrs):
        if tag in self.BLOCK:
            self.parts.append("\n")

    def handle_endtag(self, tag):
        if tag in self.BLOCK:
            self.parts.append("\n")

    def handle_data(self, data):
        self.parts.append(data)


def html_to_text(content: str) -> str:
    """Plain text version of HTML for search (Phase 1 LIKE, Phase 2 tokenisation)."""
    parser = _TextExtractor()
    parser.feed(content or "")
    text = html.unescape("".join(parser.parts))
    lines = [re.sub(r"[ \t]+", " ", line).strip() for line in text.splitlines()]
    return "\n".join(line for line in lines if line)


def make_summary(text: str, length: int = 220) -> str:
    text = " ".join(text.split())
    if len(text) <= length:
        return text
    cut = text[:length].rsplit(" ", 1)[0]
    return cut.rstrip(",.;:") + "…"


# ----------------------------------------------------------------------- audit
def audit(db: Session, actor: User | None, action: str, entity_type: str = "", entity_id: Any = "",
          detail: str = "", request: Request | None = None, commit: bool = True) -> None:
    db.add(AuditLog(actor_id=actor.id if actor else None, action=action, entity_type=entity_type,
                    entity_id=str(entity_id or ""), detail=detail[:2000],
                    ip_address=client_ip(request) if request else ""))
    if commit:
        db.commit()


# -------------------------------------------------------------------- settings
DEFAULT_SETTINGS: dict[str, Any] = {
    "site_name": "Lantern",
    "tagline": "Clear, independent explainers on technology, science and everyday life",
    "items_per_page": 9,
    "allow_registration": True,
    "comments_require_approval": False,
    "maintenance_banner": "",
    "spam_keywords": ["free money", "click here", "buy followers", "crypto giveaway", "casino bonus",
                      "work from home and earn", "cheap pills"],
}
PUBLIC_SETTINGS = ("site_name", "tagline", "items_per_page", "allow_registration", "maintenance_banner")
SUPER_ADMIN_SETTINGS = ("site_name", "tagline", "items_per_page", "allow_registration",
                        "comments_require_approval", "maintenance_banner")


def ensure_settings(db: Session) -> None:
    existing = {s.key for s in db.scalars(select(Setting))}
    for key, value in DEFAULT_SETTINGS.items():
        if key not in existing:
            db.add(Setting(key=key, value=value))
    db.commit()


def get_setting(db: Session, key: str) -> Any:
    row = db.get(Setting, key)
    return row.value if row is not None else DEFAULT_SETTINGS.get(key)


def set_setting(db: Session, key: str, value: Any, user: User | None) -> None:
    row = db.get(Setting, key)
    if row is None:
        db.add(Setting(key=key, value=value, updated_by=user.id if user else None))
    else:
        row.value = value
        row.updated_by = user.id if user else None


# ------------------------------------------------------- mentions & spam check
MENTION_RE = re.compile(r"(?<![\w@])@([A-Za-z0-9_]{3,40})")


def find_mentioned_users(db: Session, text: str, exclude_user_id: int | None = None) -> list[User]:
    names = {m.lower() for m in MENTION_RE.findall(text)}
    if not names:
        return []
    users = db.scalars(select(User).where(User.username.in_(names), User.is_active.is_(True))).all()
    return [u for u in users if u.id != exclude_user_id]


def matches_spam(db: Session, text: str) -> str | None:
    lowered = text.lower()
    for keyword in get_setting(db, "spam_keywords") or []:
        if keyword and keyword.lower() in lowered:
            return keyword
    if len(re.findall(r"https?://", lowered)) >= 3:
        return "too many links"
    return None
