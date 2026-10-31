"""Data & SEO Specialist: SEO metadata editor and analytics dashboard."""
from __future__ import annotations

from datetime import timedelta

from fastapi import APIRouter, Depends, HTTPException, Query, Request, status
from sqlalchemy import desc, func, select
from sqlalchemy.orm import Session

from app import schemas
from app.database import get_db
from app.deps import client_ip, require_permission
from app.models import Category, Comment, Document, DocumentView, Like, SearchClickLog, SeoMetadata, User, utcnow
from app.utils import audit

router = APIRouter(prefix="/api/admin", tags=["admin: seo & analytics"])
SEO_FIELDS = {"meta_title": "meta title", "meta_description": "meta description", "keywords": "keywords",
              "image_alt": "image alt text"}


def seo_completeness(seo: SeoMetadata | None) -> tuple[int, list[str]]:
    missing = [label for field, label in SEO_FIELDS.items() if not seo or not getattr(seo, field).strip()]
    if seo and seo.meta_description and not 50 <= len(seo.meta_description) <= 160:
        missing.append("description length (50-160 chars)")
    score = round(100 * (len(SEO_FIELDS) - min(len(missing), len(SEO_FIELDS))) / len(SEO_FIELDS))
    return score, missing


@router.get("/seo", response_model=schemas.Page[schemas.SeoListItem])
def seo_list(q: str = "", missing_only: bool = False, page: int = Query(1, ge=1), page_size: int = Query(20, ge=1, le=100),
             _: User = Depends(require_permission("seo.manage")), db: Session = Depends(get_db)):
    stmt = select(Document).order_by(desc(Document.published_at), desc(Document.id))
    if q:
        stmt = stmt.where(Document.title.ilike(f"%{q}%"))
    docs = db.execute(stmt).unique().scalars().all()
    items = []
    for d in docs:
        score, missing = seo_completeness(d.seo)
        if missing_only and not missing:
            continue
        items.append(schemas.SeoListItem(id=d.id, title=d.title, slug=d.slug, status=d.status,
                                         seo=schemas.SeoOut.model_validate(d.seo) if d.seo else None,
                                         completeness=score, missing=missing))
    total = len(items)
    start = (page - 1) * page_size
    return {"items": items[start:start + page_size], "total": total, "page": page, "page_size": page_size,
            "pages": max(1, -(-total // page_size))}


@router.put("/seo/{document_id}", response_model=schemas.SeoListItem)
def seo_update(document_id: int, body: schemas.SeoIn, request: Request,
               actor: User = Depends(require_permission("seo.manage")), db: Session = Depends(get_db)):
    doc = db.get(Document, document_id)
    if doc is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Article not found")
    if doc.seo is None:
        doc.seo = SeoMetadata(document_id=doc.id)
    for field, value in body.model_dump().items():
        setattr(doc.seo, field, " ".join(value.split()))
    audit(db, actor.id, "seo.update", "document", doc.id, doc.title, client_ip(request))
    db.commit()
    db.refresh(doc)
    score, missing = seo_completeness(doc.seo)
    return schemas.SeoListItem(id=doc.id, title=doc.title, slug=doc.slug, status=doc.status,
                               seo=schemas.SeoOut.model_validate(doc.seo), completeness=score, missing=missing)


@router.get("/analytics")
def analytics(days: int = Query(30, ge=1, le=365), _: User = Depends(require_permission("analytics.view")),
              db: Session = Depends(get_db)):
    """All numbers are computed from document_views, search_click_logs and engagement tables."""
    now = utcnow()
    since = now - timedelta(days=days)
    day = func.date(DocumentView.timestamp)
    daily = dict(db.execute(select(day, func.count()).where(DocumentView.timestamp >= since).group_by(day)).all())
    series = []
    for i in range(days - 1, -1, -1):
        d = (now - timedelta(days=i)).date()
        series.append({"date": d.isoformat(), "views": int(daily.get(d.isoformat(), daily.get(d, 0)))})

    top_docs = db.execute(select(Document.id, Document.title, Document.slug, func.count(DocumentView.id).label("views"))
                          .join(DocumentView, DocumentView.document_id == Document.id)
                          .where(DocumentView.timestamp >= since).group_by(Document.id, Document.title, Document.slug)
                          .order_by(desc("views")).limit(10)).all()
    searches = SearchClickLog.event_type == "search"
    in_period = SearchClickLog.timestamp >= since
    n_search = db.scalar(select(func.count()).select_from(SearchClickLog).where(searches, in_period)) or 0
    n_click = db.scalar(select(func.count()).select_from(SearchClickLog).where(SearchClickLog.event_type == "click", in_period)) or 0
    searches_with_click = db.scalar(select(func.count(func.distinct(SearchClickLog.search_id)))
                                    .where(SearchClickLog.event_type == "click", in_period)) or 0
    avg_rank = db.scalar(select(func.avg(SearchClickLog.click_rank)).where(SearchClickLog.event_type == "click", in_period))
    q_lower = func.lower(SearchClickLog.query_string)
    top_queries = db.execute(select(q_lower.label("q"), func.count().label("n"), func.avg(SearchClickLog.results_count))
                             .where(searches, in_period, SearchClickLog.query_string != "")
                             .group_by(q_lower).order_by(desc("n")).limit(10)).all()
    zero = db.execute(select(q_lower.label("q"), func.count().label("n"))
                      .where(searches, in_period, SearchClickLog.results_count == 0, SearchClickLog.query_string != "")
                      .group_by(q_lower).order_by(desc("n")).limit(10)).all()
    by_category = db.execute(select(Category.name, Category.color, func.count(DocumentView.id))
                             .join(Document, Document.category_id == Category.id)
                             .join(DocumentView, DocumentView.document_id == Document.id)
                             .where(DocumentView.timestamp >= since).group_by(Category.name, Category.color)
                             .order_by(desc(func.count(DocumentView.id)))).all()
    published_docs = db.execute(select(Document).where(Document.status == "published")).unique().scalars().all()
    complete = sum(1 for d in published_docs if not seo_completeness(d.seo)[1])
    return {
        "days": days,
        "totals": {
            "views_in_period": sum(p["views"] for p in series),
            "views_all_time": db.scalar(select(func.coalesce(func.sum(Document.views_count), 0))) or 0,
            "searches": n_search, "clicks": n_click,
            "click_through_rate": round(searches_with_click / n_search, 3) if n_search else None,
            "avg_click_rank": round(float(avg_rank), 2) if avg_rank is not None else None,
            "new_comments": db.scalar(select(func.count()).select_from(Comment).where(Comment.created_at >= since)) or 0,
            "new_likes": db.scalar(select(func.count()).select_from(Like).where(Like.created_at >= since)) or 0,
            "published_articles": len(published_docs),
            "seo_complete_articles": complete,
        },
        "daily_views": series,
        "top_documents": [{"id": i, "title": t, "slug": s, "views": v} for i, t, s, v in top_docs],
        "top_queries": [{"query": q, "searches": n, "avg_results": round(float(a or 0), 1)} for q, n, a in top_queries],
        "zero_result_queries": [{"query": q, "searches": n} for q, n in zero],
        "views_by_category": [{"category": c, "color": col, "views": v} for c, col, v in by_category],
    }
