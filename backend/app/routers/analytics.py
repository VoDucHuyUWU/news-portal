"""Data & SEO Specialist: analytics dashboard (views, engagement, search behaviour)."""
from __future__ import annotations

from datetime import timedelta

from fastapi import APIRouter, Depends, Query
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.database import get_db, utcnow
from app.deps import require_permission
from app.models import (Category, Comment, Document, DocumentView, Like, Rating, SearchClickLog, SeoMetadata,
                        User)

router = APIRouter(prefix="/api/admin/analytics", tags=["analytics"])


@router.get("")
def dashboard(days: int = Query(30, ge=1, le=365), include_seed: bool = True,
              _: User = Depends(require_permission("analytics.view")), db: Session = Depends(get_db)):
    since = utcnow() - timedelta(days=days)
    logs = select(SearchClickLog).where(SearchClickLog.timestamp >= since)
    if not include_seed:
        logs = logs.where(SearchClickLog.source == "web")
    logs = logs.subquery()

    def count(stmt) -> int:
        return db.scalar(stmt) or 0

    searches = count(select(func.count()).select_from(logs).where(logs.c.event_type == "search"))
    clicks = count(select(func.count()).select_from(logs).where(logs.c.event_type == "click"))
    searches_with_click = count(select(func.count(func.distinct(logs.c.search_log_id)))
                                .where(logs.c.event_type == "click"))
    published = select(Document).where(Document.status == "published").subquery()

    top_docs = db.execute(select(Document.id, Document.title, Document.slug, Document.views_count, Category.name)
                          .join(Category).where(Document.status == "published")
                          .order_by(Document.views_count.desc()).limit(10)).all()
    by_category = db.execute(select(Category.name, Category.color, func.count(Document.id),
                                    func.coalesce(func.sum(Document.views_count), 0))
                             .join(Document, Document.category_id == Category.id)
                             .where(Document.status == "published").group_by(Category.id)
                             .order_by(func.sum(Document.views_count).desc())).all()
    top_queries = db.execute(select(func.lower(logs.c.query_string), func.count(), func.avg(logs.c.results_count))
                             .where(logs.c.event_type == "search").group_by(func.lower(logs.c.query_string))
                             .order_by(func.count().desc()).limit(10)).all()
    zero_results = db.execute(select(func.lower(logs.c.query_string), func.count())
                              .where(logs.c.event_type == "search", logs.c.results_count == 0)
                              .group_by(func.lower(logs.c.query_string)).order_by(func.count().desc()).limit(10)).all()
    day = func.date(logs.c.timestamp)
    per_day = db.execute(select(day, func.count()).where(logs.c.event_type == "search").group_by(day)
                         .order_by(day)).all()
    click_ranks = db.execute(select(logs.c.rank_position, func.count()).where(logs.c.event_type == "click")
                             .group_by(logs.c.rank_position).order_by(logs.c.rank_position)).all()
    vday = func.date(DocumentView.timestamp)
    views_per_day = db.execute(select(vday, func.count()).where(DocumentView.timestamp >= since)
                               .group_by(vday).order_by(vday)).all()
    liked = db.execute(select(Document.title, Document.slug, func.count(Like.user_id).label("n"))
                       .join(Like, Like.document_id == Document.id).group_by(Document.id)
                       .order_by(func.count(Like.user_id).desc()).limit(5)).all()
    rated = db.execute(select(Document.title, Document.slug, func.avg(Rating.score), func.count())
                       .join(Rating, Rating.document_id == Document.id).group_by(Document.id)
                       .having(func.count() >= 2).order_by(func.avg(Rating.score).desc()).limit(5)).all()
    missing_seo = count(select(func.count()).select_from(Document).outerjoin(SeoMetadata)
                        .where(Document.status == "published",
                               (SeoMetadata.meta_description.is_(None)) | (SeoMetadata.meta_description == "")))
    missing_alt = count(select(func.count()).select_from(Document).outerjoin(SeoMetadata)
                        .where(Document.status == "published", Document.cover_image_url != "",
                               (SeoMetadata.cover_image_alt.is_(None)) | (SeoMetadata.cover_image_alt == "")))
    return {
        "window_days": days,
        "include_seed": include_seed,
        "totals": {
            "published_documents": count(select(func.count()).select_from(published)),
            "draft_documents": count(select(func.count()).select_from(Document).where(Document.status == "draft")),
            "total_views": count(select(func.coalesce(func.sum(Document.views_count), 0))),
            "users": count(select(func.count()).select_from(User)),
            "comments": count(select(func.count()).select_from(Comment).where(Comment.status == "visible")),
            "pending_comments": count(select(func.count()).select_from(Comment).where(Comment.status == "pending")),
            "likes": count(select(func.count()).select_from(Like)),
            "ratings": count(select(func.count()).select_from(Rating)),
            "searches": searches,
            "clicks": clicks,
            "click_through_rate": round(searches_with_click / searches, 3) if searches else None,
            "documents_missing_meta_description": missing_seo,
            "documents_missing_alt_text": missing_alt,
        },
        "top_documents": [{"id": i, "title": t, "slug": s, "views": v, "category": c} for i, t, s, v, c in top_docs],
        "views_by_category": [{"category": n, "color": col, "documents": d, "views": int(v)}
                              for n, col, d, v in by_category],
        "top_queries": [{"query": q, "searches": n, "avg_results": round(float(a or 0), 1)}
                        for q, n, a in top_queries],
        "zero_result_queries": [{"query": q, "searches": n} for q, n in zero_results],
        "searches_per_day": [{"date": str(d), "searches": n} for d, n in per_day],
        "views_per_day": [{"date": str(d), "views": n} for d, n in views_per_day],
        "clicks_by_rank": [{"rank": r, "clicks": n} for r, n in click_ranks if r is not None],
        "most_liked": [{"title": t, "slug": s, "likes": n} for t, s, n in liked],
        "top_rated": [{"title": t, "slug": s, "avg": round(float(a), 2), "ratings": n} for t, s, a, n in rated],
    }
