"""
Basic search (Phase 1 placeholder) and interaction logging (Phase 2 preparation).

Phase 1 ranking: every keyword must appear (case-insensitive LIKE) in the title,
summary or plain-text content; title matches are listed first, then newest first.
Phase 2 will replace ``_run_query`` with BM25/TF-IDF over an inverted index while
keeping this API and the ``search_click_logs`` format unchanged.
"""
from __future__ import annotations

import re
from datetime import date, datetime, time, timedelta

from fastapi import APIRouter, Depends, Header, HTTPException, Query, status
from sqlalchemy import and_, case, func, or_, select
from sqlalchemy.orm import Session

from app import schemas
from app.config import MAX_PAGE_SIZE
from app.database import get_db
from app.deps import get_current_user_optional
from app.models import Category, Document, SearchClickLog, Tag, User
from app.serializers import doc_card
from app.services import get_setting

router = APIRouter(prefix="/api/search", tags=["search"])
MAX_TERMS = 8


def tokenize_query(q: str) -> list[str]:
    """Split the query into keywords (quoted phrases are kept together)."""
    phrases = re.findall(r'"([^"]+)"', q)
    rest = re.sub(r'"[^"]+"', " ", q)
    words = [w for w in re.split(r"\s+", rest) if len(w) >= 2]
    terms, seen = [], set()
    for t in [p.strip() for p in phrases] + words:
        if t and t.lower() not in seen:
            seen.add(t.lower())
            terms.append(t)
    return terms[:MAX_TERMS]


def _escape_like(term: str) -> str:
    return term.replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_")


def make_snippet(text: str, terms: list[str], width: int = 240) -> str:
    """Window of plain text around the first keyword occurrence."""
    flat = " ".join(text.split())
    lowered = flat.lower()
    positions = [lowered.find(t.lower()) for t in terms if lowered.find(t.lower()) >= 0]
    start = max(0, min(positions) - width // 3) if positions else 0
    snippet = flat[start:start + width]
    if start > 0:
        snippet = "…" + snippet.split(" ", 1)[-1]
    if start + width < len(flat):
        snippet = snippet.rsplit(" ", 1)[0] + "…"
    return snippet


def _run_query(terms: list[str], category: str | None, tag: str | None, date_from: date | None,
               date_to: date | None):
    query = select(Document).where(Document.status == "published")
    for term in terms:
        like = f"%{_escape_like(term)}%"
        query = query.where(or_(Document.title.ilike(like, escape="\\"), Document.summary.ilike(like, escape="\\"),
                                Document.content_text.ilike(like, escape="\\")))
    if category:
        query = query.where(Document.category.has(Category.slug == category))
    if tag:
        query = query.where(Document.tags.any(Tag.slug == tag))
    if date_from:
        query = query.where(Document.published_at >= datetime.combine(date_from, time.min))
    if date_to:
        query = query.where(Document.published_at < datetime.combine(date_to + timedelta(days=1), time.min))
    if terms:
        title_hits = and_(*[Document.title.ilike(f"%{_escape_like(t)}%", escape="\\") for t in terms])
        order = [case((title_hits, 0), else_=1), Document.published_at.desc(), Document.id.desc()]
    else:
        order = [Document.published_at.desc(), Document.id.desc()]
    return query, order


@router.get("", response_model=schemas.SearchOut)
def search(q: str = Query("", max_length=200), category: str | None = None, tag: str | None = None,
           date_from: date | None = None, date_to: date | None = None, page: int = Query(1, ge=1),
           page_size: int | None = Query(None, ge=1, le=MAX_PAGE_SIZE),
           x_session_id: str = Header(default="", max_length=64),
           viewer: User | None = Depends(get_current_user_optional), db: Session = Depends(get_db)):
    """Keyword search + filters (category, tag, date range). Every keyword search is logged."""
    if date_from and date_to and date_from > date_to:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "'From' date is after 'To' date.")
    q = " ".join(q.split())
    terms = tokenize_query(q)
    size = min(page_size or int(get_setting(db, "items_per_page") or 9), MAX_PAGE_SIZE)
    query, order = _run_query(terms, category, tag, date_from, date_to)
    total = db.scalar(select(func.count()).select_from(query.subquery())) or 0
    docs = db.scalars(query.order_by(*order).offset((page - 1) * size).limit(size)).unique().all()

    log_id = None
    if q:  # log keyword searches (pure filter browsing is not a search)
        log = SearchClickLog(event_type="search", user_id=viewer.id if viewer else None, session_id=x_session_id,
                             query_string=q, results_count=total,
                             filters={k: v for k, v in {"category": category, "tag": tag,
                                                        "date_from": str(date_from) if date_from else None,
                                                        "date_to": str(date_to) if date_to else None,
                                                        "page": page}.items() if v})
        db.add(log)
        db.commit()
        log_id = log.id
    offset = (page - 1) * size
    items = [schemas.SearchHit(**doc_card(d).model_dump(), snippet=make_snippet(d.content_text, terms) if terms
                               else d.summary, rank=offset + i + 1) for i, d in enumerate(docs)]
    return schemas.SearchOut(items=items, page=page, page_size=size, total=total,
                             pages=max(1, -(-total // size)), query=q, search_log_id=log_id)


@router.post("/click", status_code=201)
def log_click(data: schemas.ClickIn, x_session_id: str = Header(default="", max_length=64),
              viewer: User | None = Depends(get_current_user_optional), db: Session = Depends(get_db)):
    """Record which result was clicked for a logged search (query -> clicked_doc_id)."""
    search_row = db.get(SearchClickLog, data.search_log_id)
    if search_row is None or search_row.event_type != "search":
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Unknown search_log_id.")
    if db.get(Document, data.document_id) is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Unknown document.")
    click = SearchClickLog(event_type="click", user_id=viewer.id if viewer else search_row.user_id,
                           session_id=x_session_id or search_row.session_id, query_string=search_row.query_string,
                           filters=search_row.filters, clicked_doc_id=data.document_id,
                           rank_position=data.rank_position, search_log_id=search_row.id)
    db.add(click)
    db.commit()
    return {"id": click.id}
