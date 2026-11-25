"""
Keyword search and standardised search/click logging.

Phase 2 (default): the query is tokenized and scored against an in-memory inverted index with BM25
(`ranker=bm25`) or TF-IDF (`ranker=tfidf`), see app/search_engine.py.
Phase 1 (`ranker=like`): SQL LIKE/ILIKE, kept so the two phases can be compared side by side.
The API shape and the search_click_logs format are the same for all three.
"""
from __future__ import annotations

import math
from datetime import date, datetime, time, timedelta

from fastapi import APIRouter, Depends, Header, HTTPException, Query, status
from sqlalchemy import Integer, case, desc, func, or_, select
from sqlalchemy.orm import Session

from app import schemas
from app.database import get_db
from app.deps import get_optional_user
from app.models import Category, Document, SearchClickLog, Tag, User, document_tags
from app.search_engine import InvertedIndex, query_terms
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
    """Phase 1 ranker. Every term must appear in title, summary, body or a tag (AND semantics). Title hits rank first."""
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


# ---------------------------------------------------------------- Phase 2: inverted index kept in memory
_index_cache: dict = {"signature": None, "index": None}


def get_index(db: Session) -> InvertedIndex:
    """The inverted index over published articles, rebuilt only when the collection has changed."""
    count, newest = db.execute(select(func.count(Document.id), func.max(Document.updated_at))
                               .where(Document.status == "published")).one()
    tag_names = tuple(sorted(db.scalars(select(Tag.name)).all()))
    tag_links = db.scalar(select(func.count()).select_from(document_tags)) or 0
    signature = (count, newest, tag_names, tag_links)
    if _index_cache["index"] is None or _index_cache["signature"] != signature:
        docs = db.execute(select(Document).where(Document.status == "published")).unique().scalars().all()
        _index_cache["index"] = InvertedIndex.build(
            {"id": d.id, "title": d.title, "summary": d.summary, "content_text": d.content_text,
             "tags": [t.name for t in d.tags]} for d in docs)
        _index_cache["signature"] = signature
    return _index_cache["index"]


def _apply_filters(stmt, category: str | None, tag: str | None, date_from: date | None, date_to: date | None):
    if category:
        stmt = stmt.join(Category, Category.id == Document.category_id).where(Category.slug == category)
    if tag:
        stmt = stmt.where(Document.tags.any(Tag.slug == tag))
    if date_from:
        stmt = stmt.where(Document.published_at >= datetime.combine(date_from, time.min))
    if date_to:
        stmt = stmt.where(Document.published_at < datetime.combine(date_to + timedelta(days=1), time.min))
    return stmt


def _order(stmt, sort: str):
    if sort == "oldest":
        return stmt.order_by(Document.published_at)
    if sort == "popular":
        return stmt.order_by(desc(Document.views_count))
    return stmt.order_by(desc(Document.published_at))


@router.get("", response_model=schemas.SearchResponse)
def search(q: str = Query("", max_length=200), category: str | None = None, tag: str | None = None,
           date_from: date | None = None, date_to: date | None = None,
           sort: str = Query("relevance", pattern="^(relevance|newest|oldest|popular)$"),
           ranker: str = Query("bm25", pattern="^(bm25|tfidf|like)$"),
           page: int = Query(1, ge=1), page_size: int | None = Query(None, ge=1, le=50),
           log: bool = True, x_session_id: str | None = Header(default=None),
           user: User | None = Depends(get_optional_user), db: Session = Depends(get_db)):
    if date_from and date_to and date_from > date_to:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "date_from must be before date_to")
    query = " ".join(q.split())
    size = page_size or get_int_setting(db, "page_size", 9)
    published = Document.status == "published"
    scores: dict[int, float] = {}
    if query and ranker != "like":
        # Phase 2: score with the inverted index, then keep only the documents that pass the filters.
        ranked = get_index(db).search(query, ranker) if query_terms(query) else []
        allowed = set(db.scalars(_apply_filters(select(Document.id).where(published), category, tag, date_from, date_to)).all())
        ranked = [(doc_id, score) for doc_id, score in ranked if doc_id in allowed]
        scores = {doc_id: round(score, 4) for doc_id, score in ranked}
        if not ranked:
            result = {"items": [], "total": 0, "page": page, "page_size": size, "pages": 1}
        elif sort == "relevance":
            page_ids = [doc_id for doc_id, _ in ranked][(page - 1) * size: page * size]
            by_id = {}
            if page_ids:
                by_id = {d.id: d for d in db.execute(select(Document).where(Document.id.in_(page_ids))).unique().scalars().all()}
            result = {"items": [by_id[i] for i in page_ids if i in by_id], "total": len(ranked), "page": page,
                      "page_size": size, "pages": max(1, math.ceil(len(ranked) / size))}
        else:
            result = paginate(db, _order(select(Document).where(Document.id.in_(list(scores))), sort), page, size)
        scores = {d.id: scores[d.id] for d in result["items"]}
    else:
        # Phase 1 ranker (ranker=like), and filter-only browsing without keywords.
        stmt = _apply_filters(select(Document).where(published), category, tag, date_from, date_to)
        stmt, score = _rank_and_filter(stmt, _terms(query))
        if sort == "relevance" and score is not None:
            stmt = stmt.order_by(desc(score), desc(Document.published_at))
        else:
            stmt = _order(stmt, sort)
        result = paginate(db, stmt, page, size)

    log_id = None
    filters = {k: v for k, v in {"category": category, "tag": tag, "date_from": str(date_from) if date_from else None,
                                 "date_to": str(date_to) if date_to else None, "sort": sort, "page": page,
                                 "ranker": ranker if query else None}.items() if v}
    if log and (query or category or tag or date_from or date_to):
        entry = SearchClickLog(event_type="search", user_id=user.id if user else None, session_id=x_session_id,
                               query_string=query, filters=filters, results_count=result["total"])
        db.add(entry)
        db.commit()
        log_id = entry.id
    return schemas.SearchResponse(search_log_id=log_id, query=query, ranker=ranker if query else "none", scores=scores,
                                  **result)


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
