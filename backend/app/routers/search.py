"""
Basic keyword search (Phase 1 placeholder) and standardised search/click logging.

Phase 1 ranks with SQL LIKE/ILIKE. Phase 2 will replace `_rank_and_filter` with
tokenization + inverted index + BM25/TF-IDF while keeping this API and the
search_click_logs format unchanged.
"""
from __future__ import annotations

from datetime import date, datetime, time, timedelta

from fastapi import APIRouter, Depends, Header, HTTPException, Query, status
from sqlalchemy import Integer, case, desc, or_, select
from sqlalchemy.orm import Session

from app import schemas
from app.database import get_db
from app.deps import get_optional_user
from app.models import Category, Document, SearchClickLog, Tag, User
from app.utils import escape_like, get_int_setting, paginate

router = APIRouter(prefix="/api/search", tags=["search"])
MAX_TERMS = 8


def _terms(q: str) -> list[str]:
    seen: list[str] = []
    for raw in q.lower().split():
        term = raw.strip(".,;:!?\"'()[]{}")
        if term and term not in seen:
            seen.append(term)
    return seen[:MAX_TERMS]


def _rank_and_filter(stmt, terms: list[str]):
    """Every term must appear in title, summary, body or a tag (AND semantics). Title hits rank first."""
    title_hits = []
    for term in terms:
        pattern = f"%{escape_like(term)}%"
        stmt = stmt.where(or_(Document.title.ilike(pattern, escape="\\"),
                              Document.summary.ilike(pattern, escape="\\"),
                              Document.content_text.ilike(pattern, escape="\\"),
                              Document.tags.any(Tag.name.ilike(pattern, escape="\\"))))
        title_hits.append(case((Document.title.ilike(pattern, escape="\\"), 1), else_=0))
    score = sum(title_hits[1:], title_hits[0]).cast(Integer) if title_hits else None
    return stmt, score


@router.get("", response_model=schemas.SearchResponse)
def search(q: str = Query("", max_length=200), category: str | None = None, tag: str | None = None,
           date_from: date | None = None, date_to: date | None = None,
           sort: str = Query("relevance", pattern="^(relevance|newest|oldest|popular)$"),
           page: int = Query(1, ge=1), page_size: int | None = Query(None, ge=1, le=50),
           log: bool = True, x_session_id: str | None = Header(default=None),
           user: User | None = Depends(get_optional_user), db: Session = Depends(get_db)):
    if date_from and date_to and date_from > date_to:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "date_from must be before date_to")
    query = " ".join(q.split())
    stmt = select(Document).where(Document.status == "published")
    if category:
        stmt = stmt.join(Category, Category.id == Document.category_id).where(Category.slug == category)
    if tag:
        stmt = stmt.where(Document.tags.any(Tag.slug == tag))
    if date_from:
        stmt = stmt.where(Document.published_at >= datetime.combine(date_from, time.min))
    if date_to:
        stmt = stmt.where(Document.published_at < datetime.combine(date_to + timedelta(days=1), time.min))
    stmt, score = _rank_and_filter(stmt, _terms(query))
    if sort == "relevance" and score is not None:
        stmt = stmt.order_by(desc(score), desc(Document.published_at))
    elif sort == "oldest":
        stmt = stmt.order_by(Document.published_at)
    elif sort == "popular":
        stmt = stmt.order_by(desc(Document.views_count))
    else:
        stmt = stmt.order_by(desc(Document.published_at))
    result = paginate(db, stmt, page, page_size or get_int_setting(db, "page_size", 9))

    log_id = None
    filters = {k: v for k, v in {"category": category, "tag": tag, "date_from": str(date_from) if date_from else None,
                                 "date_to": str(date_to) if date_to else None, "sort": sort, "page": page}.items() if v}
    if log and (query or category or tag or date_from or date_to):
        entry = SearchClickLog(event_type="search", user_id=user.id if user else None, session_id=x_session_id,
                               query_string=query, filters=filters, results_count=result["total"])
        db.add(entry)
        db.commit()
        log_id = entry.id
    return schemas.SearchResponse(search_log_id=log_id, query=query, **result)


@router.post("/click", status_code=201)
def click(body: schemas.ClickIn, x_session_id: str | None = Header(default=None),
          user: User | None = Depends(get_optional_user), db: Session = Depends(get_db)):
    search_row = db.get(SearchClickLog, body.search_log_id)
    if search_row is None or search_row.event_type != "search":
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Search log entry not found")
    if db.get(Document, body.document_id) is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Document not found")
    db.add(SearchClickLog(event_type="click", user_id=user.id if user else search_row.user_id,
                          session_id=x_session_id or search_row.session_id, query_string=search_row.query_string,
                          filters=search_row.filters, search_id=search_row.id, clicked_doc_id=body.document_id,
                          click_rank=body.rank))
    db.commit()
    return {"ok": True}
