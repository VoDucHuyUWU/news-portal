"""Convert ORM objects into response schemas (adds computed fields)."""
from __future__ import annotations

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app import schemas
from app.models import Comment, Document, Like, Rating, User


def user_out(user: User) -> schemas.UserOut:
    return schemas.UserOut(
        id=user.id, username=user.username, full_name=user.full_name, avatar_url=user.avatar_url,
        email=user.email, bio=user.bio, role=user.role.name, role_label=user.role.label,
        is_active=user.is_active, is_muted=user.is_muted, created_at=user.created_at,
        last_login_at=user.last_login_at)


def me_out(user: User) -> schemas.MeOut:
    return schemas.MeOut(**user_out(user).model_dump(), permissions=sorted(user.permissions))


def _seo(doc: Document) -> schemas.SeoOut:
    return schemas.SeoOut.model_validate(doc.seo) if doc.seo else schemas.SeoOut()


def _card_fields(doc: Document) -> dict:
    words = len((doc.content_text or "").split())
    return dict(
        id=doc.id, title=doc.title, slug=doc.slug, summary=doc.summary,
        category=schemas.CategoryBrief.model_validate(doc.category),
        tags=[schemas.TagBrief.model_validate(t) for t in doc.tags],
        author=schemas.UserBrief.model_validate(doc.author),
        cover_image_url=doc.cover_image_url, cover_image_alt=doc.seo.cover_image_alt if doc.seo else "",
        status=doc.status, published_at=doc.published_at, created_at=doc.created_at,
        views_count=doc.views_count, reading_minutes=max(1, round(words / 220)))


def doc_card(doc: Document) -> schemas.DocumentCard:
    return schemas.DocumentCard(**_card_fields(doc))


def doc_admin(doc: Document) -> schemas.DocumentAdmin:
    return schemas.DocumentAdmin(**_card_fields(doc), content=doc.content, content_text=doc.content_text,
                                 updated_at=doc.updated_at, seo=_seo(doc))


def doc_detail(db: Session, doc: Document, viewer: User | None) -> schemas.DocumentDetail:
    like_count = db.scalar(select(func.count()).select_from(Like).where(Like.document_id == doc.id)) or 0
    rating_avg, rating_count = db.execute(
        select(func.avg(Rating.score), func.count()).where(Rating.document_id == doc.id)).one()
    comment_count = db.scalar(select(func.count()).select_from(Comment).where(
        Comment.document_id == doc.id, Comment.status == "visible")) or 0
    my_like, my_rating = False, None
    if viewer is not None:
        my_like = db.get(Like, (viewer.id, doc.id)) is not None
        rating = db.get(Rating, (viewer.id, doc.id))
        my_rating = rating.score if rating else None
    return schemas.DocumentDetail(
        **_card_fields(doc), content=doc.content, updated_at=doc.updated_at, seo=_seo(doc),
        like_count=like_count, rating_avg=round(float(rating_avg), 2) if rating_avg is not None else None,
        rating_count=rating_count or 0, comment_count=comment_count, my_like=my_like, my_rating=my_rating)


def comment_out(comment: Comment) -> schemas.CommentOut:
    return schemas.CommentOut(
        id=comment.id, document_id=comment.document_id, parent_id=comment.parent_id, content=comment.content,
        status=comment.status, created_at=comment.created_at, updated_at=comment.updated_at,
        user=schemas.UserBrief.model_validate(comment.user),
        mentions=[schemas.UserBrief.model_validate(u) for u in comment.mentions])


def comment_admin_out(comment: Comment) -> schemas.CommentAdminOut:
    return schemas.CommentAdminOut(**comment_out(comment).model_dump(),
                                   document_title=comment.document.title, document_slug=comment.document.slug)


def paginate(total: int, page: int, page_size: int, items: list) -> schemas.Page:
    return schemas.Page(items=items, page=page, page_size=page_size, total=total,
                        pages=max(1, -(-total // page_size)))
