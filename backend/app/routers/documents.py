"""Documents: public directory/detail and the Content Manager / SEO admin API."""
from __future__ import annotations

from typing import Literal

from fastapi import APIRouter, Depends, HTTPException, Query, Request, status
from sqlalchemy import func, or_, select
from sqlalchemy.orm import Session

from app import schemas
from app.config import MAX_PAGE_SIZE
from app.database import get_db, utcnow
from app.deps import get_current_user_optional, require_permission
from app.models import Category, Document, DocumentView, SeoMetadata, Tag, User
from app.serializers import doc_admin, doc_card, doc_detail, paginate
from app.services import audit, get_setting, html_to_text, make_summary, sanitize_html, slugify, unique_slug

router = APIRouter(tags=["documents"])
STAFF_DOC_PERMS = ("document.create", "document.update", "document.delete", "document.publish", "seo.manage")


def _page_size(db: Session, page_size: int | None) -> int:
    return min(page_size or int(get_setting(db, "items_per_page") or 9), MAX_PAGE_SIZE)


def published_query():
    return select(Document).where(Document.status == "published")


# ------------------------------------------------------------------ public
@router.get("/api/documents", response_model=schemas.Page)
def list_documents(page: int = Query(1, ge=1), page_size: int | None = Query(None, ge=1, le=MAX_PAGE_SIZE),
                   category: str | None = None, tag: str | None = None, author: str | None = None,
                   sort: Literal["latest", "popular"] = "latest", db: Session = Depends(get_db)):
    """Home & directory: paginated list of the latest published documents with summaries."""
    size = _page_size(db, page_size)
    query = published_query()
    if category:
        query = query.join(Category).where(Category.slug == category)
    if tag:
        query = query.where(Document.tags.any(Tag.slug == tag))
    if author:
        query = query.join(User, Document.author_id == User.id).where(func.lower(User.username) == author.lower())
    total = db.scalar(select(func.count()).select_from(query.subquery())) or 0
    order = Document.views_count.desc() if sort == "popular" else Document.published_at.desc()
    docs = db.scalars(query.order_by(order, Document.id.desc()).offset((page - 1) * size).limit(size)).unique().all()
    return paginate(total, page, size, [doc_card(d) for d in docs])


@router.get("/api/documents/{slug}", response_model=schemas.DocumentDetail)
def get_document(slug: str, db: Session = Depends(get_db), viewer: User | None = Depends(get_current_user_optional)):
    """Detail view: full content and metadata. Each request counts one view."""
    doc = db.scalar(published_query().where(Document.slug == slug))
    if doc is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Article not found.")
    doc.views_count += 1
    db.add(DocumentView(document_id=doc.id, user_id=viewer.id if viewer else None))
    db.commit()
    return doc_detail(db, doc, viewer)


# -------------------------------------------------------------------- admin
def _resolve_tags(db: Session, names: list[str], user: User) -> list[Tag]:
    tags, seen = [], set()
    for raw in names:
        name = " ".join(raw.split())
        if not name or name.lower() in seen:
            continue
        seen.add(name.lower())
        tag = db.scalar(select(Tag).where(or_(func.lower(Tag.name) == name.lower(), Tag.slug == slugify(name))))
        if tag is None:
            if not user.can("taxonomy.manage"):
                raise HTTPException(status.HTTP_403_FORBIDDEN, f"Tag {name!r} does not exist and you "
                                                               "cannot create tags (taxonomy.manage).")
            tag = Tag(name=name, slug=unique_slug(db, Tag, name))
            db.add(tag)
            db.flush()
        tags.append(tag)
    return tags


def _apply(db: Session, doc: Document, data: schemas.DocumentIn, user: User) -> None:
    if db.get(Category, data.category_id) is None:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "Unknown category.")
    if data.author_id is not None and data.author_id != doc.author_id:
        if not user.can("document.update") or db.get(User, data.author_id) is None:
            raise HTTPException(status.HTTP_400_BAD_REQUEST, "Invalid author.")
        doc.author_id = data.author_id
    doc.title = data.title.strip()
    doc.content = sanitize_html(data.content)
    doc.content_text = html_to_text(doc.content)
    if len(doc.content_text) < 20:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "Content is too short.")
    doc.summary = data.summary.strip() or make_summary(doc.content_text)
    doc.category_id = data.category_id
    doc.cover_image_url = data.cover_image_url.strip()
    doc.tags = _resolve_tags(db, data.tags, user)
    _set_status(doc, data.status, user)


def _set_status(doc: Document, new_status: str, user: User) -> None:
    if new_status != doc.status:
        if not user.can("document.publish"):
            raise HTTPException(status.HTTP_403_FORBIDDEN, "You cannot publish or unpublish (document.publish).")
        doc.status = new_status
        if new_status == "published" and doc.published_at is None:
            doc.published_at = utcnow()


def _get(db: Session, doc_id: int) -> Document:
    doc = db.get(Document, doc_id)
    if doc is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Document not found.")
    return doc


@router.get("/api/admin/documents", response_model=schemas.Page)
def admin_list(page: int = Query(1, ge=1), page_size: int = Query(20, ge=1, le=MAX_PAGE_SIZE),
               status_: Literal["draft", "published"] | None = Query(None, alias="status"),
               q: str | None = None, category_id: int | None = None,
               _: User = Depends(require_permission(*STAFF_DOC_PERMS)), db: Session = Depends(get_db)):
    query = select(Document)
    if status_:
        query = query.where(Document.status == status_)
    if category_id:
        query = query.where(Document.category_id == category_id)
    if q:
        query = query.where(Document.title.ilike(f"%{q}%"))
    total = db.scalar(select(func.count()).select_from(query.subquery())) or 0
    docs = db.scalars(query.order_by(Document.updated_at.desc(), Document.id.desc())
                      .offset((page - 1) * page_size).limit(page_size)).unique().all()
    return paginate(total, page, page_size, [doc_card(d) for d in docs])


@router.get("/api/admin/documents/{doc_id}", response_model=schemas.DocumentAdmin)
def admin_get(doc_id: int, _: User = Depends(require_permission(*STAFF_DOC_PERMS)), db: Session = Depends(get_db)):
    return doc_admin(_get(db, doc_id))


@router.post("/api/admin/documents", response_model=schemas.DocumentAdmin, status_code=201)
def admin_create(data: schemas.DocumentIn, request: Request,
                 user: User = Depends(require_permission("document.create")), db: Session = Depends(get_db)):
    doc = Document(author_id=user.id, slug=unique_slug(db, Document, data.title), status="draft",
                   content="", content_text="", category_id=data.category_id)
    db.add(doc)
    _apply(db, doc, data, user)
    doc.seo = SeoMetadata(meta_title=doc.title[:70], meta_description=doc.summary[:320])
    db.flush()
    audit(db, user, "document.create", "document", doc.id, f"{doc.title} [{doc.status}]", request)
    db.refresh(doc)
    return doc_admin(doc)


@router.put("/api/admin/documents/{doc_id}", response_model=schemas.DocumentAdmin)
def admin_update(doc_id: int, data: schemas.DocumentIn, request: Request,
                 user: User = Depends(require_permission("document.update")), db: Session = Depends(get_db)):
    doc = _get(db, doc_id)
    if data.title.strip() != doc.title:
        doc.slug = unique_slug(db, Document, data.title, exclude_id=doc.id)
    _apply(db, doc, data, user)
    doc.updated_at = utcnow()
    audit(db, user, "document.update", "document", doc.id, doc.title, request)
    db.refresh(doc)
    return doc_admin(doc)


@router.delete("/api/admin/documents/{doc_id}", status_code=204)
def admin_delete(doc_id: int, request: Request, user: User = Depends(require_permission("document.delete")),
                 db: Session = Depends(get_db)):
    doc = _get(db, doc_id)
    title = doc.title
    db.delete(doc)
    audit(db, user, "document.delete", "document", doc_id, title, request)


@router.post("/api/admin/documents/{doc_id}/publish", response_model=schemas.DocumentAdmin)
def admin_publish(doc_id: int, request: Request, user: User = Depends(require_permission("document.publish")),
                  db: Session = Depends(get_db)):
    doc = _get(db, doc_id)
    _set_status(doc, "published", user)
    audit(db, user, "document.publish", "document", doc.id, doc.title, request)
    return doc_admin(doc)


@router.post("/api/admin/documents/{doc_id}/unpublish", response_model=schemas.DocumentAdmin)
def admin_unpublish(doc_id: int, request: Request, user: User = Depends(require_permission("document.publish")),
                    db: Session = Depends(get_db)):
    doc = _get(db, doc_id)
    _set_status(doc, "draft", user)
    audit(db, user, "document.unpublish", "document", doc.id, doc.title, request)
    return doc_admin(doc)


@router.put("/api/admin/documents/{doc_id}/seo", response_model=schemas.DocumentAdmin)
def admin_update_seo(doc_id: int, data: schemas.SeoIn, request: Request,
                     user: User = Depends(require_permission("seo.manage")), db: Session = Depends(get_db)):
    """Data & SEO Specialist: titles, descriptions, keywords and cover-image alt text."""
    doc = _get(db, doc_id)
    if doc.seo is None:
        doc.seo = SeoMetadata()
    for field, value in data.model_dump().items():
        setattr(doc.seo, field, value.strip())
    doc.seo.updated_by = user.id
    audit(db, user, "seo.update", "document", doc.id, doc.title, request)
    db.refresh(doc)
    return doc_admin(doc)
