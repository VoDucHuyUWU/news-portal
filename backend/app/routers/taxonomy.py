"""Categories, tags (taxonomy) and image uploads."""
from __future__ import annotations

import uuid

from fastapi import APIRouter, Depends, File, HTTPException, Request, UploadFile, status
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app import schemas
from app.config import ALLOWED_IMAGE_TYPES, MAX_UPLOAD_BYTES, UPLOAD_DIR
from app.database import get_db
from app.deps import require_permission
from app.models import Category, Document, Tag, User, document_tags
from app.services import audit, unique_slug

router = APIRouter(tags=["taxonomy"])


def _category_counts(db: Session) -> dict[int, int]:
    rows = db.execute(select(Document.category_id, func.count()).where(Document.status == "published")
                      .group_by(Document.category_id)).all()
    return dict(rows)


def _tag_counts(db: Session) -> dict[int, int]:
    rows = db.execute(select(document_tags.c.tag_id, func.count()).join(Document)
                      .where(Document.status == "published").group_by(document_tags.c.tag_id)).all()
    return dict(rows)


@router.get("/api/categories", response_model=list[schemas.CategoryOut])
def list_categories(db: Session = Depends(get_db)):
    counts = _category_counts(db)
    return [schemas.CategoryOut(**schemas.CategoryOut.model_validate(c).model_dump(exclude={"document_count"}),
                                document_count=counts.get(c.id, 0))
            for c in db.scalars(select(Category).order_by(Category.name))]


@router.get("/api/tags", response_model=list[schemas.TagOut])
def list_tags(db: Session = Depends(get_db)):
    counts = _tag_counts(db)
    return [schemas.TagOut(id=t.id, name=t.name, slug=t.slug, document_count=counts.get(t.id, 0))
            for t in db.scalars(select(Tag).order_by(Tag.name))]


# ------------------------------------------------------------- categories
@router.post("/api/admin/categories", response_model=schemas.CategoryOut, status_code=201)
def create_category(data: schemas.CategoryIn, request: Request,
                    user: User = Depends(require_permission("taxonomy.manage")), db: Session = Depends(get_db)):
    if db.scalar(select(Category).where(func.lower(Category.name) == data.name.strip().lower())):
        raise HTTPException(status.HTTP_409_CONFLICT, "A category with this name already exists.")
    cat = Category(name=data.name.strip(), slug=unique_slug(db, Category, data.name),
                   description=data.description.strip(), color=data.color)
    db.add(cat)
    db.flush()
    audit(db, user, "category.create", "category", cat.id, cat.name, request)
    return schemas.CategoryOut.model_validate(cat)


@router.put("/api/admin/categories/{cat_id}", response_model=schemas.CategoryOut)
def update_category(cat_id: int, data: schemas.CategoryIn, request: Request,
                    user: User = Depends(require_permission("taxonomy.manage")), db: Session = Depends(get_db)):
    cat = db.get(Category, cat_id)
    if cat is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Category not found.")
    clash = db.scalar(select(Category).where(func.lower(Category.name) == data.name.strip().lower(),
                                             Category.id != cat_id))
    if clash:
        raise HTTPException(status.HTTP_409_CONFLICT, "A category with this name already exists.")
    if data.name.strip() != cat.name:
        cat.slug = unique_slug(db, Category, data.name, exclude_id=cat.id)
    cat.name, cat.description, cat.color = data.name.strip(), data.description.strip(), data.color
    audit(db, user, "category.update", "category", cat.id, cat.name, request)
    return schemas.CategoryOut(**schemas.CategoryOut.model_validate(cat).model_dump(exclude={"document_count"}),
                               document_count=_category_counts(db).get(cat.id, 0))


@router.delete("/api/admin/categories/{cat_id}", status_code=204)
def delete_category(cat_id: int, request: Request, user: User = Depends(require_permission("taxonomy.manage")),
                    db: Session = Depends(get_db)):
    cat = db.get(Category, cat_id)
    if cat is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Category not found.")
    in_use = db.scalar(select(func.count()).select_from(Document).where(Document.category_id == cat_id))
    if in_use:
        raise HTTPException(status.HTTP_409_CONFLICT,
                            f"{in_use} document(s) still use this category. Move them first.")
    db.delete(cat)
    audit(db, user, "category.delete", "category", cat_id, cat.name, request)


# ------------------------------------------------------------------- tags
@router.post("/api/admin/tags", response_model=schemas.TagOut, status_code=201)
def create_tag(data: schemas.TagIn, request: Request, user: User = Depends(require_permission("taxonomy.manage")),
               db: Session = Depends(get_db)):
    name = " ".join(data.name.split())
    if db.scalar(select(Tag).where(func.lower(Tag.name) == name.lower())):
        raise HTTPException(status.HTTP_409_CONFLICT, "This tag already exists.")
    tag = Tag(name=name, slug=unique_slug(db, Tag, name))
    db.add(tag)
    db.flush()
    audit(db, user, "tag.create", "tag", tag.id, tag.name, request)
    return schemas.TagOut(id=tag.id, name=tag.name, slug=tag.slug)


@router.put("/api/admin/tags/{tag_id}", response_model=schemas.TagOut)
def update_tag(tag_id: int, data: schemas.TagIn, request: Request,
               user: User = Depends(require_permission("taxonomy.manage")), db: Session = Depends(get_db)):
    tag = db.get(Tag, tag_id)
    if tag is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Tag not found.")
    name = " ".join(data.name.split())
    if db.scalar(select(Tag).where(func.lower(Tag.name) == name.lower(), Tag.id != tag_id)):
        raise HTTPException(status.HTTP_409_CONFLICT, "This tag already exists.")
    if name != tag.name:
        tag.slug = unique_slug(db, Tag, name, exclude_id=tag.id)
    tag.name = name
    audit(db, user, "tag.update", "tag", tag.id, tag.name, request)
    return schemas.TagOut(id=tag.id, name=tag.name, slug=tag.slug, document_count=_tag_counts(db).get(tag.id, 0))


@router.delete("/api/admin/tags/{tag_id}", status_code=204)
def delete_tag(tag_id: int, request: Request, user: User = Depends(require_permission("taxonomy.manage")),
               db: Session = Depends(get_db)):
    tag = db.get(Tag, tag_id)
    if tag is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Tag not found.")
    db.delete(tag)  # removes it from documents too (document_tags rows cascade)
    audit(db, user, "tag.delete", "tag", tag_id, tag.name, request)


# ---------------------------------------------------------------- uploads
MAGIC = {b"\x89PNG": "image/png", b"\xff\xd8\xff": "image/jpeg", b"GIF8": "image/gif", b"RIFF": "image/webp"}


@router.post("/api/admin/uploads", status_code=201)
async def upload_image(request: Request, file: UploadFile = File(...),
                       user: User = Depends(require_permission("media.upload")), db: Session = Depends(get_db)):
    """Upload a PNG/JPEG/GIF/WebP image (max 5 MB). Returns its public URL."""
    data = await file.read(MAX_UPLOAD_BYTES + 1)
    if len(data) > MAX_UPLOAD_BYTES:
        raise HTTPException(status.HTTP_413_REQUEST_ENTITY_TOO_LARGE, "Image is larger than 5 MB.")
    detected = next((mime for sig, mime in MAGIC.items() if data.startswith(sig)), None)
    if detected not in ALLOWED_IMAGE_TYPES:
        raise HTTPException(status.HTTP_415_UNSUPPORTED_MEDIA_TYPE, "Only PNG, JPEG, GIF or WebP images.")
    name = f"{uuid.uuid4().hex}{ALLOWED_IMAGE_TYPES[detected]}"
    (UPLOAD_DIR / name).write_bytes(data)
    audit(db, user, "media.upload", "file", name, file.filename or "", request)
    return {"url": f"/uploads/{name}", "filename": name}
