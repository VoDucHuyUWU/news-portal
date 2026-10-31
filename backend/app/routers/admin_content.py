"""Content Manager: article CRUD, publication status, categories, tags, image uploads."""
from __future__ import annotations

import uuid

from fastapi import APIRouter, Depends, File, HTTPException, Query, Request, UploadFile, status
from sqlalchemy import desc, func, or_, select
from sqlalchemy.orm import Session

from app import schemas
from app.config import settings
from app.database import get_db
from app.deps import client_ip, require_permission
from app.models import Category, Document, SeoMetadata, Tag, User, document_tags, utcnow
from app.utils import audit, html_to_text, make_summary, paginate, sanitize_html, unique_slug

router = APIRouter(prefix="/api/admin", tags=["admin: content"])
CONTENT_READERS = ("documents.manage", "documents.publish", "seo.manage")
IMAGE_TYPES = {"image/png": ".png", "image/jpeg": ".jpg", "image/gif": ".gif", "image/webp": ".webp"}


def _get_doc(db: Session, document_id: int) -> Document:
    doc = db.get(Document, document_id)
    if doc is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Article not found")
    return doc


@router.get("/documents", response_model=schemas.Page[schemas.DocumentAdmin])
def list_documents(q: str = "", status_: str | None = Query(None, alias="status", pattern="^(draft|published)$"),
                   category_id: int | None = None, page: int = Query(1, ge=1), page_size: int = Query(20, ge=1, le=100),
                   _: User = Depends(require_permission(*CONTENT_READERS)), db: Session = Depends(get_db)):
    stmt = select(Document).order_by(desc(Document.updated_at), desc(Document.id))
    if q:
        stmt = stmt.where(or_(Document.title.ilike(f"%{q}%"), Document.summary.ilike(f"%{q}%")))
    if status_:
        stmt = stmt.where(Document.status == status_)
    if category_id:
        stmt = stmt.where(Document.category_id == category_id)
    return paginate(db, stmt, page, page_size)


@router.get("/documents/{document_id}", response_model=schemas.DocumentAdmin)
def get_document(document_id: int, _: User = Depends(require_permission(*CONTENT_READERS)), db: Session = Depends(get_db)):
    return _get_doc(db, document_id)


@router.get("/authors", response_model=list[schemas.UserPublic])
def authors(_: User = Depends(require_permission("documents.manage")), db: Session = Depends(get_db)):
    """Staff accounts that can be credited as authors."""
    staff = [u for u in db.execute(select(User).where(User.is_active.is_(True)).order_by(User.full_name)).scalars()
             if u.permission_codes & {"documents.manage", "documents.publish"}]
    return staff


def _resolve_tags(db: Session, tag_ids: list[int], new_tags: list[str]) -> list[Tag]:
    tags = db.execute(select(Tag).where(Tag.id.in_(tag_ids or [-1]))).scalars().all() if tag_ids else []
    for name in new_tags:
        name = " ".join(name.split())[:60]
        if len(name) < 2:
            continue
        existing = db.execute(select(Tag).where(func.lower(Tag.name) == name.lower())).scalar_one_or_none()
        if existing is None:
            existing = Tag(name=name, slug=unique_slug(db, Tag, name))
            db.add(existing)
            db.flush()
        if existing not in tags:
            tags.append(existing)
    return list(tags)


def _apply(db: Session, doc: Document, body: schemas.DocumentIn, actor: User) -> None:
    if body.category_id is not None and db.get(Category, body.category_id) is None:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "Unknown category")
    if body.author_id is not None and db.get(User, body.author_id) is None:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "Unknown author")
    clean = sanitize_html(body.content)
    doc.title = body.title.strip()
    doc.content = clean
    doc.content_text = html_to_text(clean)
    doc.summary = body.summary.strip() or make_summary(doc.content_text)
    doc.category_id = body.category_id
    doc.author_id = body.author_id or doc.author_id or actor.id
    doc.cover_image_url = body.cover_image_url or None
    doc.tags = _resolve_tags(db, body.tag_ids, body.new_tags)
    if body.status != doc.status:
        if "documents.publish" not in actor.permission_codes:
            raise HTTPException(status.HTTP_403_FORBIDDEN, "Missing permission: documents.publish")
        doc.status = body.status
        if body.status == "published" and doc.published_at is None:
            doc.published_at = utcnow()


@router.post("/documents", response_model=schemas.DocumentAdmin, status_code=201)
def create_document(body: schemas.DocumentIn, request: Request,
                    actor: User = Depends(require_permission("documents.manage")), db: Session = Depends(get_db)):
    doc = Document(title=body.title, slug=unique_slug(db, Document, body.title), content="", status="draft")
    _apply(db, doc, body, actor)
    db.add(doc)
    db.flush()
    db.add(SeoMetadata(document_id=doc.id, meta_title=doc.title[:255], meta_description=doc.summary[:500]))
    audit(db, actor.id, "document.create", "document", doc.id, doc.title, client_ip(request))
    db.commit()
    db.refresh(doc)
    return doc


@router.put("/documents/{document_id}", response_model=schemas.DocumentAdmin)
def update_document(document_id: int, body: schemas.DocumentIn, request: Request,
                    actor: User = Depends(require_permission("documents.manage")), db: Session = Depends(get_db)):
    doc = _get_doc(db, document_id)
    if body.title.strip() != doc.title:
        doc.slug = unique_slug(db, Document, body.title, exclude_id=doc.id)
    _apply(db, doc, body, actor)
    doc.updated_at = utcnow()
    audit(db, actor.id, "document.update", "document", doc.id, doc.title, client_ip(request))
    db.commit()
    db.refresh(doc)
    return doc


@router.delete("/documents/{document_id}", status_code=204)
def delete_document(document_id: int, request: Request, actor: User = Depends(require_permission("documents.manage")),
                    db: Session = Depends(get_db)):
    doc = _get_doc(db, document_id)
    audit(db, actor.id, "document.delete", "document", doc.id, doc.title, client_ip(request))
    db.delete(doc)
    db.commit()


def _set_status(db: Session, document_id: int, new_status: str, actor: User, ip: str) -> Document:
    doc = _get_doc(db, document_id)
    doc.status = new_status
    if new_status == "published" and doc.published_at is None:
        doc.published_at = utcnow()
    audit(db, actor.id, f"document.{'publish' if new_status == 'published' else 'unpublish'}", "document", doc.id,
          doc.title, ip)
    db.commit()
    db.refresh(doc)
    return doc


@router.post("/documents/{document_id}/publish", response_model=schemas.DocumentAdmin)
def publish(document_id: int, request: Request, actor: User = Depends(require_permission("documents.publish")),
            db: Session = Depends(get_db)):
    return _set_status(db, document_id, "published", actor, client_ip(request))


@router.post("/documents/{document_id}/unpublish", response_model=schemas.DocumentAdmin)
def unpublish(document_id: int, request: Request, actor: User = Depends(require_permission("documents.publish")),
              db: Session = Depends(get_db)):
    return _set_status(db, document_id, "draft", actor, client_ip(request))


# ------------------------------------------------------------------ taxonomy
def _doc_counts_by_category(db: Session) -> dict[int, int]:
    return dict(db.execute(select(Document.category_id, func.count()).group_by(Document.category_id)).all())


@router.get("/categories", response_model=list[schemas.CategoryWithCount])
def list_categories(_: User = Depends(require_permission("taxonomy.manage", "documents.manage")),
                    db: Session = Depends(get_db)):
    counts = _doc_counts_by_category(db)
    return [schemas.CategoryWithCount(**schemas.CategoryOut.model_validate(c).model_dump(), document_count=counts.get(c.id, 0))
            for c in db.execute(select(Category).order_by(Category.name)).scalars()]


@router.post("/categories", response_model=schemas.CategoryOut, status_code=201)
def create_category(body: schemas.CategoryIn, request: Request, actor: User = Depends(require_permission("taxonomy.manage")),
                    db: Session = Depends(get_db)):
    if db.execute(select(Category).where(func.lower(Category.name) == body.name.lower())).first():
        raise HTTPException(status.HTTP_409_CONFLICT, "A category with this name already exists")
    cat = Category(name=body.name.strip(), slug=unique_slug(db, Category, body.name), description=body.description,
                   color=body.color)
    db.add(cat)
    db.flush()
    audit(db, actor.id, "category.create", "category", cat.id, cat.name, client_ip(request))
    db.commit()
    return cat


@router.put("/categories/{category_id}", response_model=schemas.CategoryOut)
def update_category(category_id: int, body: schemas.CategoryIn, request: Request,
                    actor: User = Depends(require_permission("taxonomy.manage")), db: Session = Depends(get_db)):
    cat = db.get(Category, category_id)
    if cat is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Category not found")
    if body.name.strip() != cat.name:
        cat.slug = unique_slug(db, Category, body.name, exclude_id=cat.id)
    cat.name, cat.description, cat.color = body.name.strip(), body.description, body.color
    audit(db, actor.id, "category.update", "category", cat.id, cat.name, client_ip(request))
    db.commit()
    return cat


@router.delete("/categories/{category_id}", status_code=204)
def delete_category(category_id: int, request: Request, actor: User = Depends(require_permission("taxonomy.manage")),
                    db: Session = Depends(get_db)):
    cat = db.get(Category, category_id)
    if cat is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Category not found")
    for doc in db.execute(select(Document).where(Document.category_id == cat.id)).unique().scalars():
        doc.category_id = None  # articles are kept, just uncategorised
    audit(db, actor.id, "category.delete", "category", cat.id, cat.name, client_ip(request))
    db.delete(cat)
    db.commit()


@router.get("/tags", response_model=list[schemas.TagWithCount])
def list_tags(_: User = Depends(require_permission("taxonomy.manage", "documents.manage")), db: Session = Depends(get_db)):
    counts = dict(db.execute(select(document_tags.c.tag_id, func.count()).group_by(document_tags.c.tag_id)).all())
    return [schemas.TagWithCount(**schemas.TagOut.model_validate(t).model_dump(), document_count=counts.get(t.id, 0))
            for t in db.execute(select(Tag).order_by(Tag.name)).scalars()]


@router.post("/tags", response_model=schemas.TagOut, status_code=201)
def create_tag(body: schemas.TagIn, request: Request, actor: User = Depends(require_permission("taxonomy.manage")),
               db: Session = Depends(get_db)):
    if db.execute(select(Tag).where(func.lower(Tag.name) == body.name.lower())).first():
        raise HTTPException(status.HTTP_409_CONFLICT, "A tag with this name already exists")
    tag = Tag(name=body.name.strip(), slug=unique_slug(db, Tag, body.name))
    db.add(tag)
    db.flush()
    audit(db, actor.id, "tag.create", "tag", tag.id, tag.name, client_ip(request))
    db.commit()
    return tag


@router.put("/tags/{tag_id}", response_model=schemas.TagOut)
def update_tag(tag_id: int, body: schemas.TagIn, request: Request, actor: User = Depends(require_permission("taxonomy.manage")),
               db: Session = Depends(get_db)):
    tag = db.get(Tag, tag_id)
    if tag is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Tag not found")
    if body.name.strip() != tag.name:
        tag.slug = unique_slug(db, Tag, body.name, exclude_id=tag.id)
    tag.name = body.name.strip()
    audit(db, actor.id, "tag.update", "tag", tag.id, tag.name, client_ip(request))
    db.commit()
    return tag


@router.delete("/tags/{tag_id}", status_code=204)
def delete_tag(tag_id: int, request: Request, actor: User = Depends(require_permission("taxonomy.manage")),
               db: Session = Depends(get_db)):
    tag = db.get(Tag, tag_id)
    if tag is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Tag not found")
    audit(db, actor.id, "tag.delete", "tag", tag.id, tag.name, client_ip(request))
    db.delete(tag)
    db.commit()


# ------------------------------------------------------------------ uploads
@router.post("/uploads", status_code=201)
async def upload_image(file: UploadFile = File(...),
                       actor: User = Depends(require_permission("documents.manage", "seo.manage"))):
    ext = IMAGE_TYPES.get(file.content_type or "")
    if ext is None:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "Only PNG, JPEG, GIF or WebP images are allowed")
    data = await file.read(settings.max_upload_mb * 1024 * 1024 + 1)
    if len(data) > settings.max_upload_mb * 1024 * 1024:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, f"Image is larger than {settings.max_upload_mb} MB")
    folder = settings.media_dir / "uploads"
    folder.mkdir(parents=True, exist_ok=True)
    name = f"{uuid.uuid4().hex}{ext}"
    (folder / name).write_bytes(data)
    return {"url": f"/media/uploads/{name}"}
