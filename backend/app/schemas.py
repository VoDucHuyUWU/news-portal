"""Pydantic request/response models (the public API contract)."""
from __future__ import annotations

from datetime import date, datetime
from typing import Any, Generic, Literal, TypeVar

from pydantic import BaseModel, ConfigDict, EmailStr, Field, field_serializer

T = TypeVar("T")


class ORM(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    @field_serializer("*", when_used="json", check_fields=False)
    def _utc(self, value: Any) -> Any:  # timestamps are stored as naive UTC
        if isinstance(value, datetime) and value.tzinfo is None:
            return value.isoformat() + "Z"
        return value


class Page(BaseModel, Generic[T]):
    items: list[T]
    total: int
    page: int
    page_size: int
    pages: int


# ---------------------------------------------------------------- users / auth
class RoleOut(ORM):
    id: int
    name: str
    label: str


class UserPublic(ORM):
    id: int
    username: str
    full_name: str
    avatar_url: str | None = None
    bio: str = ""


class UserMe(UserPublic):
    email: str
    role: RoleOut
    permissions: list[str]
    created_at: datetime


class RegisterIn(BaseModel):
    username: str = Field(min_length=3, max_length=40, pattern=r"^[A-Za-z0-9_]+$")
    email: EmailStr
    password: str = Field(min_length=8, max_length=128)
    full_name: str = Field(default="", max_length=120)


class LoginIn(BaseModel):
    login: str = Field(description="username or email")
    password: str


class TokenOut(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserMe


class ProfileUpdate(BaseModel):
    full_name: str | None = Field(default=None, max_length=120)
    bio: str | None = Field(default=None, max_length=1000)
    avatar_url: str | None = Field(default=None, max_length=500)
    email: EmailStr | None = None


class PasswordChange(BaseModel):
    current_password: str
    new_password: str = Field(min_length=8, max_length=128)


# ---------------------------------------------------------------- taxonomy
class CategoryOut(ORM):
    id: int
    name: str
    slug: str
    description: str = ""
    color: str


class CategoryWithCount(CategoryOut):
    document_count: int = 0


class CategoryIn(BaseModel):
    name: str = Field(min_length=2, max_length=80)
    description: str = Field(default="", max_length=500)
    color: str = Field(default="#3D5AFE", pattern=r"^#[0-9A-Fa-f]{6}$")


class TagOut(ORM):
    id: int
    name: str
    slug: str


class TagWithCount(TagOut):
    document_count: int = 0


class TagIn(BaseModel):
    name: str = Field(min_length=2, max_length=60)


# ---------------------------------------------------------------- documents
class SeoOut(ORM):
    meta_title: str = ""
    meta_description: str = ""
    keywords: str = ""
    image_alt: str = ""


class SeoIn(BaseModel):
    meta_title: str = Field(default="", max_length=255)
    meta_description: str = Field(default="", max_length=500)
    keywords: str = Field(default="", max_length=500)
    image_alt: str = Field(default="", max_length=255)


class DocumentCard(ORM):
    id: int
    title: str
    slug: str
    summary: str
    cover_image_url: str | None
    category: CategoryOut | None
    tags: list[TagOut]
    author: UserPublic | None
    created_at: datetime
    published_at: datetime | None
    views_count: int


class DocumentDetail(DocumentCard):
    content: str
    seo: SeoOut | None
    like_count: int = 0
    rating_avg: float | None = None
    rating_count: int = 0
    comment_count: int = 0
    liked_by_me: bool = False
    my_rating: int | None = None
    reading_minutes: int = 1


class DocumentAdmin(DocumentCard):
    content: str
    content_text: str
    status: str
    updated_at: datetime
    seo: SeoOut | None


class DocumentIn(BaseModel):
    title: str = Field(min_length=3, max_length=255)
    summary: str = Field(default="", max_length=1000)
    content: str = Field(min_length=1)
    category_id: int | None = None
    tag_ids: list[int] = []
    new_tags: list[str] = Field(default=[], description="tag names to create on the fly")
    author_id: int | None = None
    cover_image_url: str | None = Field(default=None, max_length=500)
    status: Literal["draft", "published"] = "draft"


# ---------------------------------------------------------------- engagement
class CommentOut(ORM):
    id: int
    document_id: int
    parent_id: int | None
    content: str
    status: str
    created_at: datetime
    user: UserPublic
    mentions: list[str] = []


class CommentIn(BaseModel):
    content: str = Field(min_length=1, max_length=3000)
    parent_id: int | None = None


class RatingIn(BaseModel):
    score: int = Field(ge=1, le=5)


class EngagementOut(BaseModel):
    like_count: int
    liked_by_me: bool
    rating_avg: float | None
    rating_count: int
    my_rating: int | None


class ReportIn(BaseModel):
    target_type: Literal["comment", "document"]
    target_id: int
    reason: str = Field(min_length=3, max_length=500)


class MentionOut(BaseModel):
    comment_id: int
    content: str
    created_at: datetime
    by: UserPublic
    document_title: str
    document_slug: str


# ---------------------------------------------------------------- search
class SearchResponse(BaseModel):
    search_log_id: int | None
    query: str
    items: list[DocumentCard]
    total: int
    page: int
    page_size: int
    pages: int


class ClickIn(BaseModel):
    search_log_id: int
    document_id: int
    rank: int = Field(ge=1)


# ---------------------------------------------------------------- admin
class UserAdmin(ORM):
    id: int
    username: str
    email: str
    full_name: str
    role: RoleOut
    is_active: bool
    created_at: datetime
    last_login_at: datetime | None


class UserAdminUpdate(BaseModel):
    role_id: int | None = None
    is_active: bool | None = None
    full_name: str | None = None


class UserAdminCreate(RegisterIn):
    role_id: int


class RoleDetail(ORM):
    id: int
    name: str
    label: str
    description: str
    permissions: list[str]
    user_count: int = 0


class PermissionOut(ORM):
    id: int
    code: str
    description: str


class RolePermissionsIn(BaseModel):
    permissions: list[str]


class AuditLogOut(ORM):
    id: int
    action: str
    entity: str
    entity_id: str
    detail: str
    ip_address: str
    timestamp: datetime
    actor: UserPublic | None


class SearchLogOut(ORM):
    id: int
    event_type: str
    user_id: int | None
    query_string: str
    filters: dict | None
    results_count: int | None
    search_id: int | None
    clicked_doc_id: int | None
    click_rank: int | None
    timestamp: datetime


class CommentAdmin(CommentOut):
    flag_reason: str
    document_title: str
    document_slug: str
    report_count: int = 0


class CommentModerateIn(BaseModel):
    status: Literal["visible", "hidden", "spam", "pending"]


class ReportOut(ORM):
    id: int
    target_type: str
    target_id: int
    reason: str
    status: str
    resolution_note: str
    created_at: datetime
    handled_at: datetime | None
    reporter: UserPublic | None
    target_preview: str = ""
    target_link: str = ""


class ReportHandleIn(BaseModel):
    status: Literal["resolved", "dismissed"]
    action: Literal["none", "hide", "spam", "unpublish"] = "none"
    note: str = Field(default="", max_length=500)


class SpamRulesIn(BaseModel):
    spam_keywords: str = Field(default="", max_length=5000)
    max_links_per_comment: int = Field(ge=0, le=50)
    comment_rate_limit_per_minute: int = Field(ge=1, le=100)
    comments_require_approval: bool


class SeoListItem(BaseModel):
    id: int
    title: str
    slug: str
    status: str
    seo: SeoOut | None
    completeness: int
    missing: list[str]


class DateRange(BaseModel):
    date_from: date | None = None
    date_to: date | None = None
