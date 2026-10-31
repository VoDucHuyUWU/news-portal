"""Pydantic request/response models."""
from __future__ import annotations

from datetime import date, datetime
from typing import Annotated, Any, Literal

from pydantic import BaseModel, ConfigDict, EmailStr, Field, PlainSerializer, field_validator

# Timestamps are stored as naive UTC; serialise them explicitly as UTC ("Z").
UTCDateTime = Annotated[datetime, PlainSerializer(lambda d: d.isoformat(timespec="seconds") + "Z",
                                                  return_type=str)]


class ORM(BaseModel):
    model_config = ConfigDict(from_attributes=True)


# --------------------------------------------------------------------- users
class UserBrief(ORM):
    id: int
    username: str
    full_name: str
    avatar_url: str


class UserOut(UserBrief):
    email: str
    bio: str
    role: str
    role_label: str
    is_active: bool
    is_muted: bool
    created_at: UTCDateTime
    last_login_at: UTCDateTime | None = None


class MeOut(UserOut):
    permissions: list[str]


class PublicProfile(UserBrief):
    bio: str
    role_label: str
    created_at: UTCDateTime
    comment_count: int
    recent_comments: list[dict[str, Any]]


USERNAME_PATTERN = r"^[a-zA-Z0-9_]{3,40}$"


class RegisterIn(BaseModel):
    username: str = Field(pattern=USERNAME_PATTERN)
    email: EmailStr
    password: str = Field(min_length=8, max_length=128)
    full_name: str = Field(default="", max_length=120)

    @field_validator("username")
    @classmethod
    def lower(cls, v: str) -> str:
        return v.lower()


class LoginIn(BaseModel):
    username: str = Field(description="Username or email")
    password: str


class TokenOut(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: MeOut


class ProfileUpdate(BaseModel):
    full_name: str | None = Field(default=None, max_length=120)
    bio: str | None = Field(default=None, max_length=1000)
    avatar_url: str | None = Field(default=None, max_length=500)
    email: EmailStr | None = None


class PasswordChange(BaseModel):
    current_password: str
    new_password: str = Field(min_length=8, max_length=128)


class AdminUserCreate(RegisterIn):
    role: str = "user"


class AdminUserUpdate(BaseModel):
    role: str | None = None
    is_active: bool | None = None
    is_muted: bool | None = None
    full_name: str | None = Field(default=None, max_length=120)


# ------------------------------------------------------------------ taxonomy
class CategoryIn(BaseModel):
    name: str = Field(min_length=2, max_length=80)
    description: str = Field(default="", max_length=500)
    color: str = Field(default="#33415c", pattern=r"^#[0-9a-fA-F]{6}$")


class CategoryOut(ORM):
    id: int
    name: str
    slug: str
    description: str
    color: str
    document_count: int = 0


class TagIn(BaseModel):
    name: str = Field(min_length=2, max_length=60)


class TagOut(ORM):
    id: int
    name: str
    slug: str
    document_count: int = 0


# ----------------------------------------------------------------- documents
class SeoOut(ORM):
    meta_title: str = ""
    meta_description: str = ""
    keywords: str = ""
    cover_image_alt: str = ""


class SeoIn(BaseModel):
    meta_title: str = Field(default="", max_length=70)
    meta_description: str = Field(default="", max_length=320)
    keywords: str = Field(default="", max_length=500)
    cover_image_alt: str = Field(default="", max_length=255)


class CategoryBrief(ORM):
    id: int
    name: str
    slug: str
    color: str


class TagBrief(ORM):
    id: int
    name: str
    slug: str


class DocumentCard(ORM):
    id: int
    title: str
    slug: str
    summary: str
    category: CategoryBrief
    tags: list[TagBrief]
    author: UserBrief
    cover_image_url: str
    cover_image_alt: str = ""
    status: str
    published_at: UTCDateTime | None
    created_at: UTCDateTime
    views_count: int
    reading_minutes: int = 1


class DocumentDetail(DocumentCard):
    content: str
    updated_at: UTCDateTime
    like_count: int = 0
    rating_avg: float | None = None
    rating_count: int = 0
    comment_count: int = 0
    my_like: bool = False
    my_rating: int | None = None
    seo: SeoOut


class DocumentAdmin(DocumentCard):
    content: str
    content_text: str
    updated_at: UTCDateTime
    seo: SeoOut


class DocumentIn(BaseModel):
    title: str = Field(min_length=5, max_length=255)
    content: str = Field(min_length=20)
    summary: str = Field(default="", max_length=600)
    category_id: int
    tags: list[str] = Field(default_factory=list, description="Tag names; unknown tags are created")
    cover_image_url: str = Field(default="", max_length=500)
    status: Literal["draft", "published"] = "draft"
    author_id: int | None = Field(default=None, description="Defaults to the current user")


class Page(BaseModel):
    items: list[Any]
    page: int
    page_size: int
    total: int
    pages: int


# ---------------------------------------------------------------- engagement
class CommentIn(BaseModel):
    content: str = Field(min_length=1, max_length=2000)
    parent_id: int | None = None


class CommentOut(ORM):
    id: int
    document_id: int
    parent_id: int | None
    content: str
    status: str
    created_at: UTCDateTime
    updated_at: UTCDateTime | None
    user: UserBrief
    mentions: list[UserBrief]


class CommentAdminOut(CommentOut):
    document_title: str
    document_slug: str


class RatingIn(BaseModel):
    score: int = Field(ge=1, le=5)


class ReportIn(BaseModel):
    target_type: Literal["comment", "document"]
    target_id: int
    reason: str = Field(min_length=3, max_length=500)


class ReportOut(ORM):
    id: int
    target_type: str
    target_id: int
    reason: str
    status: str
    resolution_note: str
    created_at: UTCDateTime
    handled_at: UTCDateTime | None
    reporter: UserBrief
    target_preview: str = ""
    target_link: str = ""


class ReportResolve(BaseModel):
    status: Literal["resolved", "dismissed"]
    note: str = Field(default="", max_length=500)
    hide_target: bool = False


class CommentStatusIn(BaseModel):
    status: Literal["visible", "pending", "hidden", "spam"]


# -------------------------------------------------------------------- search
class SearchHit(DocumentCard):
    snippet: str
    rank: int


class SearchOut(BaseModel):
    items: list[SearchHit]
    page: int
    page_size: int
    total: int
    pages: int
    query: str
    search_log_id: int | None


class ClickIn(BaseModel):
    search_log_id: int
    document_id: int
    rank_position: int = Field(ge=1)


class SearchLogOut(ORM):
    id: int
    event_type: str
    user_id: int | None
    session_id: str
    query_string: str
    filters: dict
    results_count: int | None
    clicked_doc_id: int | None
    rank_position: int | None
    search_log_id: int | None
    source: str
    timestamp: UTCDateTime


# --------------------------------------------------------------- admin/system
class AuditOut(ORM):
    id: int
    action: str
    entity_type: str
    entity_id: str
    detail: str
    ip_address: str
    timestamp: UTCDateTime
    actor: UserBrief | None


class RolePermissionsIn(BaseModel):
    permissions: list[str]


class SettingsIn(BaseModel):
    site_name: str | None = Field(default=None, min_length=2, max_length=60)
    tagline: str | None = Field(default=None, max_length=160)
    items_per_page: int | None = Field(default=None, ge=3, le=50)
    allow_registration: bool | None = None
    comments_require_approval: bool | None = None
    maintenance_banner: str | None = Field(default=None, max_length=300)


class SpamKeywordsIn(BaseModel):
    keywords: list[str] = Field(max_length=200)


class DateRange(BaseModel):
    date_from: date | None = None
    date_to: date | None = None
