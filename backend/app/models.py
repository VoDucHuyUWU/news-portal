"""
Database schema.

Phase 2 (search engine) relies on two tables defined here:

* ``documents``          - the Document Store. Required fields: id, title, content (HTML),
                           summary, category_id, tags, author, created_at, views_count.
                           ``content_text`` keeps a plain-text copy of ``content`` so the
                           tokenizer / inverted index can read it without stripping HTML.
                           Tags and author are normalised (``document_tags`` table and
                           ``author_id`` foreign key); the API returns them inline.
* ``search_click_logs``  - one row per interaction event. Required fields: user_id,
                           query_string, clicked_doc_id, timestamp. A search creates an
                           ``event_type='search'`` row (clicked_doc_id NULL); a click on a
                           result creates an ``event_type='click'`` row that points back to
                           its search (``search_log_id``) and records ``rank_position``.
                           ``source='seed'`` marks demo rows so they can be excluded later.
"""
from __future__ import annotations

from datetime import datetime

from sqlalchemy import JSON, Boolean, Column, DateTime, ForeignKey, Index, Integer, String, Table, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base, utcnow

# --------------------------------------------------------------------------- RBAC
role_permissions = Table(
    "role_permissions", Base.metadata,
    Column("role_id", ForeignKey("roles.id", ondelete="CASCADE"), primary_key=True),
    Column("permission_id", ForeignKey("permissions.id", ondelete="CASCADE"), primary_key=True),
)


class Role(Base):
    __tablename__ = "roles"
    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String(40), unique=True)
    label: Mapped[str] = mapped_column(String(80))
    description: Mapped[str] = mapped_column(String(255), default="")
    permissions: Mapped[list[Permission]] = relationship(secondary=role_permissions, lazy="selectin")

    @property
    def permission_codes(self) -> set[str]:
        return {p.code for p in self.permissions}


class Permission(Base):
    __tablename__ = "permissions"
    id: Mapped[int] = mapped_column(primary_key=True)
    code: Mapped[str] = mapped_column(String(60), unique=True)
    description: Mapped[str] = mapped_column(String(255), default="")


class User(Base):
    __tablename__ = "users"
    id: Mapped[int] = mapped_column(primary_key=True)
    username: Mapped[str] = mapped_column(String(40), unique=True, index=True)
    email: Mapped[str] = mapped_column(String(255), unique=True)
    password_hash: Mapped[str] = mapped_column(String(255))
    full_name: Mapped[str] = mapped_column(String(120), default="")
    bio: Mapped[str] = mapped_column(Text, default="")
    avatar_url: Mapped[str] = mapped_column(String(500), default="")
    role_id: Mapped[int] = mapped_column(ForeignKey("roles.id"))
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    is_muted: Mapped[bool] = mapped_column(Boolean, default=False)  # spam control: cannot comment
    created_at: Mapped[datetime] = mapped_column(DateTime, default=utcnow)
    last_login_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    role: Mapped[Role] = relationship(lazy="joined")

    @property
    def permissions(self) -> set[str]:
        return self.role.permission_codes if self.role else set()

    def can(self, *codes: str) -> bool:
        return any(code in self.permissions for code in codes)


# ---------------------------------------------------------------------- taxonomy
document_tags = Table(
    "document_tags", Base.metadata,
    Column("document_id", ForeignKey("documents.id", ondelete="CASCADE"), primary_key=True),
    Column("tag_id", ForeignKey("tags.id", ondelete="CASCADE"), primary_key=True),
)


class Category(Base):
    __tablename__ = "categories"
    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String(80), unique=True)
    slug: Mapped[str] = mapped_column(String(100), unique=True, index=True)
    description: Mapped[str] = mapped_column(String(500), default="")
    color: Mapped[str] = mapped_column(String(9), default="#33415c")


class Tag(Base):
    __tablename__ = "tags"
    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String(60), unique=True)
    slug: Mapped[str] = mapped_column(String(80), unique=True, index=True)


# ---------------------------------------------------------------- document store
class Document(Base):
    __tablename__ = "documents"
    id: Mapped[int] = mapped_column(primary_key=True)
    title: Mapped[str] = mapped_column(String(255))
    slug: Mapped[str] = mapped_column(String(280), unique=True, index=True)
    content: Mapped[str] = mapped_column(Text)            # sanitised HTML
    content_text: Mapped[str] = mapped_column(Text)       # plain text for Phase 2 tokenisation
    summary: Mapped[str] = mapped_column(Text, default="")
    category_id: Mapped[int] = mapped_column(ForeignKey("categories.id"), index=True)
    author_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
    cover_image_url: Mapped[str] = mapped_column(String(500), default="")
    status: Mapped[str] = mapped_column(String(12), default="draft", index=True)  # draft | published
    published_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True, index=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=utcnow, index=True)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=utcnow, onupdate=utcnow)
    views_count: Mapped[int] = mapped_column(Integer, default=0)

    category: Mapped[Category] = relationship(lazy="joined")
    author: Mapped[User] = relationship(lazy="joined")
    tags: Mapped[list[Tag]] = relationship(secondary=document_tags, lazy="selectin", order_by="Tag.name")
    seo: Mapped[SeoMetadata | None] = relationship(back_populates="document", uselist=False, lazy="selectin",
                                                   cascade="all, delete-orphan")


class SeoMetadata(Base):
    __tablename__ = "seo_metadata"
    document_id: Mapped[int] = mapped_column(ForeignKey("documents.id", ondelete="CASCADE"), primary_key=True)
    meta_title: Mapped[str] = mapped_column(String(70), default="")
    meta_description: Mapped[str] = mapped_column(String(320), default="")
    keywords: Mapped[str] = mapped_column(String(500), default="")
    cover_image_alt: Mapped[str] = mapped_column(String(255), default="")
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=utcnow, onupdate=utcnow)
    updated_by: Mapped[int | None] = mapped_column(ForeignKey("users.id"), nullable=True)
    document: Mapped[Document] = relationship(back_populates="seo")


# -------------------------------------------------------------------- engagement
class Comment(Base):
    __tablename__ = "comments"
    id: Mapped[int] = mapped_column(primary_key=True)
    document_id: Mapped[int] = mapped_column(ForeignKey("documents.id", ondelete="CASCADE"), index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
    parent_id: Mapped[int | None] = mapped_column(ForeignKey("comments.id", ondelete="CASCADE"), nullable=True)
    content: Mapped[str] = mapped_column(Text)
    status: Mapped[str] = mapped_column(String(12), default="visible", index=True)  # visible|pending|hidden|spam
    created_at: Mapped[datetime] = mapped_column(DateTime, default=utcnow)
    updated_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    moderated_by: Mapped[int | None] = mapped_column(ForeignKey("users.id"), nullable=True)
    moderated_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    user: Mapped[User] = relationship(foreign_keys=[user_id], lazy="joined")
    document: Mapped[Document] = relationship(lazy="joined")
    mentions: Mapped[list[User]] = relationship(secondary="comment_mentions", lazy="selectin")


class CommentMention(Base):
    """User tagging: an @username inside a comment."""
    __tablename__ = "comment_mentions"
    comment_id: Mapped[int] = mapped_column(ForeignKey("comments.id", ondelete="CASCADE"), primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), primary_key=True)


class Like(Base):
    __tablename__ = "likes"
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), primary_key=True)
    document_id: Mapped[int] = mapped_column(ForeignKey("documents.id", ondelete="CASCADE"), primary_key=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=utcnow)


class Rating(Base):
    __tablename__ = "ratings"
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), primary_key=True)
    document_id: Mapped[int] = mapped_column(ForeignKey("documents.id", ondelete="CASCADE"), primary_key=True)
    score: Mapped[int] = mapped_column(Integer)  # 1..5
    created_at: Mapped[datetime] = mapped_column(DateTime, default=utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=utcnow, onupdate=utcnow)


class Report(Base):
    __tablename__ = "reports"
    id: Mapped[int] = mapped_column(primary_key=True)
    reporter_id: Mapped[int] = mapped_column(ForeignKey("users.id"))
    target_type: Mapped[str] = mapped_column(String(12))  # comment | document
    target_id: Mapped[int] = mapped_column(Integer)
    reason: Mapped[str] = mapped_column(String(500))
    status: Mapped[str] = mapped_column(String(12), default="open", index=True)  # open|resolved|dismissed
    resolution_note: Mapped[str] = mapped_column(String(500), default="")
    handled_by: Mapped[int | None] = mapped_column(ForeignKey("users.id"), nullable=True)
    handled_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=utcnow)
    reporter: Mapped[User] = relationship(foreign_keys=[reporter_id], lazy="joined")


# ------------------------------------------------------- interaction logs (Phase 2)
class SearchClickLog(Base):
    __tablename__ = "search_click_logs"
    id: Mapped[int] = mapped_column(primary_key=True)
    event_type: Mapped[str] = mapped_column(String(10), index=True)  # search | click
    user_id: Mapped[int | None] = mapped_column(ForeignKey("users.id", ondelete="SET NULL"), nullable=True, index=True)
    session_id: Mapped[str] = mapped_column(String(64), default="")
    query_string: Mapped[str] = mapped_column(String(500), index=True)
    filters: Mapped[dict] = mapped_column(JSON, default=dict)
    results_count: Mapped[int | None] = mapped_column(Integer, nullable=True)
    clicked_doc_id: Mapped[int | None] = mapped_column(ForeignKey("documents.id", ondelete="SET NULL"),
                                                       nullable=True, index=True)
    rank_position: Mapped[int | None] = mapped_column(Integer, nullable=True)  # 1-based position of the click
    search_log_id: Mapped[int | None] = mapped_column(ForeignKey("search_click_logs.id", ondelete="SET NULL"),
                                                      nullable=True)
    source: Mapped[str] = mapped_column(String(10), default="web")  # web | seed
    timestamp: Mapped[datetime] = mapped_column(DateTime, default=utcnow, index=True)


class DocumentView(Base):
    __tablename__ = "document_views"
    id: Mapped[int] = mapped_column(primary_key=True)
    document_id: Mapped[int] = mapped_column(ForeignKey("documents.id", ondelete="CASCADE"), index=True)
    user_id: Mapped[int | None] = mapped_column(ForeignKey("users.id", ondelete="SET NULL"), nullable=True)
    source: Mapped[str] = mapped_column(String(10), default="web")
    timestamp: Mapped[datetime] = mapped_column(DateTime, default=utcnow, index=True)


# ------------------------------------------------------------- system & settings
class AuditLog(Base):
    __tablename__ = "audit_logs"
    id: Mapped[int] = mapped_column(primary_key=True)
    actor_id: Mapped[int | None] = mapped_column(ForeignKey("users.id", ondelete="SET NULL"), nullable=True)
    action: Mapped[str] = mapped_column(String(60), index=True)
    entity_type: Mapped[str] = mapped_column(String(40), default="")
    entity_id: Mapped[str] = mapped_column(String(40), default="")
    detail: Mapped[str] = mapped_column(Text, default="")
    ip_address: Mapped[str] = mapped_column(String(64), default="")
    timestamp: Mapped[datetime] = mapped_column(DateTime, default=utcnow, index=True)
    actor: Mapped[User | None] = relationship(lazy="joined")


class Setting(Base):
    __tablename__ = "settings"
    key: Mapped[str] = mapped_column(String(60), primary_key=True)
    value: Mapped[dict | list | str | int | bool | None] = mapped_column(JSON)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=utcnow, onupdate=utcnow)
    updated_by: Mapped[int | None] = mapped_column(ForeignKey("users.id", ondelete="SET NULL"), nullable=True)


Index("ix_documents_status_published", Document.status, Document.published_at)
