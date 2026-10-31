"""Public reading API plus reader engagement (comments, likes, ratings, reports)."""
from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import and_, desc, func, or_, select, update
from sqlalchemy.orm import Session

from app import schemas
from app.database import get_db
from app.deps import get_current_user, get_optional_user
from app.models import (Category, Comment, Document, DocumentView, Like, Rating, Report, Setting, Tag, User,
                        document_tags)
from app.rbac import PUBLIC_SETTINGS
from app.services import (comment_rate_exceeded, comments_out, document_detail, engagement, initial_comment_status,
                          save_mentions)
from app.utils import get_int_setting, get_setting, paginate

router = APIRouter(prefix="/api", tags=["public"])


def published():
    return Document.status == "published"


@router.get("/settings/public")
def public_settings(db: Session = Depends(get_db)):
    return {key: get_setting(db, key) for key in PUBLIC_SETTINGS}


@router.get("/categories", response_model=list[schemas.CategoryWithCount])
def categories(db: Session = Depends(get_db)):
    counts = dict(db.execute(select(Document.category_id, func.count()).where(published())
                             .group_by(Document.category_id)).all())
    cats = db.execute(select(Category).order_by(Category.name)).scalars().all()
    return [schemas.CategoryWithCount(**schemas.CategoryOut.model_validate(c).model_dump(),
                                      document_count=counts.get(c.id, 0)) for c in cats]


@router.get("/tags", response_model=list[schemas.TagWithCount])
def tags(db: Session = Depends(get_db)):
    counts = dict(db.execute(select(document_tags.c.tag_id, func.count())
                             .join(Document, Document.id == document_tags.c.document_id)
                             .where(published()).group_by(document_tags.c.tag_id)).all())
    rows = db.execute(select(Tag).order_by(Tag.name)).scalars().all()
    return [schemas.TagWithCount(**schemas.TagOut.model_validate(t).model_dump(), document_count=counts.get(t.id, 0))
            for t in rows]


@router.get("/documents", response_model=schemas.Page[schemas.DocumentCard])
def list_documents(page: int = Query(1, ge=1), page_size: int | None = Query(None, ge=1, le=50),
                   category: str | None = None, tag: str | None = None, author: str | None = None,
                   sort: str = Query("latest", pattern="^(latest|popular|oldest)$"), db: Session = Depends(get_db)):
    """Home & directory: paginated published articles, newest first."""
    stmt = select(Document).where(published())
    if category:
        stmt = stmt.join(Category, Category.id == Document.category_id).where(Category.slug == category)
    if tag:
        stmt = stmt.where(Document.tags.any(Tag.slug == tag))
    if author:
        stmt = stmt.where(Document.author.has(func.lower(User.username) == author.lower()))
    order = {"latest": (desc(Document.published_at), desc(Document.id)),
             "oldest": (Document.published_at, Document.id),
             "popular": (desc(Document.views_count), desc(Document.id))}[sort]
    return paginate(db, stmt.order_by(*order), page, page_size or get_int_setting(db, "page_size", 9))


@router.get("/documents/popular", response_model=list[schemas.DocumentCard])
def popular(limit: int = Query(5, ge=1, le=20), db: Session = Depends(get_db)):
    return db.execute(select(Document).where(published()).order_by(desc(Document.views_count))
                      .limit(limit)).unique().scalars().all()


def _get_published(db: Session, slug: str, user: User | None) -> Document:
    doc = db.execute(select(Document).where(Document.slug == slug)).unique().scalar_one_or_none()
    can_preview = user is not None and bool({"documents.manage", "documents.publish", "seo.manage"} & user.permission_codes)
    if doc is None or (doc.status != "published" and not can_preview):
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Article not found")
    return doc


@router.get("/documents/{slug}", response_model=schemas.DocumentDetail)
def get_document(slug: str, count_view: bool = True, user: User | None = Depends(get_optional_user),
                 db: Session = Depends(get_db)):
    doc = _get_published(db, slug, user)
    if count_view and doc.status == "published":
        db.execute(update(Document).where(Document.id == doc.id).values(views_count=Document.views_count + 1))
        db.add(DocumentView(document_id=doc.id, user_id=user.id if user else None))
        db.commit()
        db.refresh(doc)
    return document_detail(db, doc, user)


@router.get("/documents/{slug}/related", response_model=list[schemas.DocumentCard])
def related(slug: str, limit: int = Query(3, ge=1, le=10), db: Session = Depends(get_db)):
    doc = _get_published(db, slug, None)
    tag_ids = [t.id for t in doc.tags]
    shared = (select(func.count()).select_from(document_tags)
              .where(and_(document_tags.c.document_id == Document.id, document_tags.c.tag_id.in_(tag_ids or [-1])))
              .scalar_subquery())
    stmt = (select(Document).where(published(), Document.id != doc.id,
                                   or_(Document.category_id == doc.category_id, shared > 0))
            .order_by(desc(shared), desc(Document.published_at)).limit(limit))
    return db.execute(stmt).unique().scalars().all()


def _doc_or_404(db: Session, document_id: int) -> Document:
    doc = db.get(Document, document_id)
    if doc is None or doc.status != "published":
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Article not found")
    return doc


@router.post("/documents/{document_id}/like", response_model=schemas.EngagementOut)
def toggle_like(document_id: int, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    _doc_or_404(db, document_id)
    existing = db.get(Like, (user.id, document_id))
    if existing:
        db.delete(existing)
    else:
        db.add(Like(user_id=user.id, document_id=document_id))
    db.commit()
    return engagement(db, document_id, user)


@router.put("/documents/{document_id}/rating", response_model=schemas.EngagementOut)
def rate(document_id: int, body: schemas.RatingIn, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    _doc_or_404(db, document_id)
    existing = db.get(Rating, (user.id, document_id))
    if existing:
        existing.score = body.score
    else:
        db.add(Rating(user_id=user.id, document_id=document_id, score=body.score))
    db.commit()
    return engagement(db, document_id, user)


@router.delete("/documents/{document_id}/rating", response_model=schemas.EngagementOut)
def unrate(document_id: int, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    existing = db.get(Rating, (user.id, document_id))
    if existing:
        db.delete(existing)
        db.commit()
    return engagement(db, document_id, user)


@router.get("/documents/{document_id}/comments", response_model=list[schemas.CommentOut])
def list_comments(document_id: int, user: User | None = Depends(get_optional_user), db: Session = Depends(get_db)):
    _doc_or_404(db, document_id)
    visibility = Comment.status == "visible"
    if user is not None:  # authors also see their own comments that await moderation
        visibility = or_(visibility, and_(Comment.user_id == user.id, Comment.status == "pending"))
    rows = db.execute(select(Comment).where(Comment.document_id == document_id, visibility)
                      .order_by(Comment.created_at)).unique().scalars().all()
    return comments_out(db, rows)


@router.post("/documents/{document_id}/comments", response_model=schemas.CommentOut, status_code=201)
def add_comment(document_id: int, body: schemas.CommentIn, user: User = Depends(get_current_user),
                db: Session = Depends(get_db)):
    _doc_or_404(db, document_id)
    if body.parent_id is not None:
        parent = db.get(Comment, body.parent_id)
        if parent is None or parent.document_id != document_id:
            raise HTTPException(status.HTTP_400_BAD_REQUEST, "Reply target not found on this article")
    if comment_rate_exceeded(db, user.id):
        raise HTTPException(status.HTTP_429_TOO_MANY_REQUESTS, "You are commenting too fast. Please wait a minute.")
    text = body.content.strip()
    status_, reason = initial_comment_status(db, text, user)
    comment = Comment(document_id=document_id, user_id=user.id, parent_id=body.parent_id, content=text,
                      status=status_, flag_reason=reason)
    db.add(comment)
    db.flush()
    save_mentions(db, comment)
    db.commit()
    return comments_out(db, [comment])[0]


@router.delete("/comments/{comment_id}", status_code=204)
def delete_own_comment(comment_id: int, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    comment = db.get(Comment, comment_id)
    if comment is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Comment not found")
    if comment.user_id != user.id and "comments.moderate" not in user.permission_codes:
        raise HTTPException(status.HTTP_403_FORBIDDEN, "You can only delete your own comments")
    db.delete(comment)
    db.commit()


@router.post("/reports", status_code=201)
def report(body: schemas.ReportIn, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    target = db.get(Comment if body.target_type == "comment" else Document, body.target_id)
    if target is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, f"{body.target_type.capitalize()} not found")
    duplicate = db.execute(select(Report).where(Report.reporter_id == user.id, Report.target_type == body.target_type,
                                                Report.target_id == body.target_id, Report.status == "open")).first()
    if duplicate:
        return {"ok": True, "message": "You have already reported this. A moderator will review it."}
    db.add(Report(reporter_id=user.id, target_type=body.target_type, target_id=body.target_id, reason=body.reason.strip()))
    db.commit()
    return {"ok": True, "message": "Thanks. A moderator will review your report."}


@router.get("/health")
def health(db: Session = Depends(get_db)):
    db.execute(select(func.count()).select_from(Setting))
    return {"status": "ok"}


# ------------------------------------------------------------------ magazine views
def _published_by_ids(db: Session, ranked: list[tuple[int, float]]) -> list[tuple[Document, float]]:
    """Fetch published documents for (id, value) pairs, keeping the ranking order."""
    if not ranked:
        return []
    docs = {d.id: d for d in db.execute(select(Document).where(published(), Document.id.in_([i for i, _ in ranked])))
            .unique().scalars()}
    return [(docs[i], v) for i, v in ranked if i in docs]


def _card(doc: Document, value: float | None = None, label: str | None = None) -> dict:
    out = {"doc": schemas.DocumentCard.model_validate(doc).model_dump(mode="json")}
    if value is not None:
        out["value"] = round(float(value), 2)
    if label:
        out["label"] = label
    return out


def _counts(db: Session, column, since, extra=None, limit: int = 50) -> list[tuple[int, float]]:
    stmt = select(column, func.count()).where(column.isnot(None))
    if since is not None:
        stmt = stmt.where(since)
    if extra is not None:
        stmt = stmt.where(extra)
    return [(i, n) for i, n in db.execute(stmt.group_by(column).order_by(desc(func.count())).limit(limit)).all()]


def _since(days: int):
    from datetime import timedelta

    from app.models import utcnow
    return utcnow() - timedelta(days=days)


@router.get("/front-page")
def front_page(db: Session = Depends(get_db)):
    """
    The magazine cover. One cover story = the published article with the highest attention
    score over the last 7 days (views + 4 x search clicks + 3 x likes + 2 x comments),
    followed by the newest, most searched and most read articles.
    """
    from app.models import SearchClickLog
    week, month = _since(7), _since(30)
    score: dict[int, float] = {}
    for weight, rows in (
        (1, _counts(db, DocumentView.document_id, DocumentView.timestamp >= week, limit=500)),
        (4, _counts(db, SearchClickLog.clicked_doc_id, SearchClickLog.timestamp >= week, SearchClickLog.event_type == "click", 500)),
        (3, _counts(db, Like.document_id, Like.created_at >= week, limit=500)),
        (2, _counts(db, Comment.document_id, Comment.created_at >= week, Comment.status == "visible", 500)),
    ):
        for doc_id, n in rows:
            score[doc_id] = score.get(doc_id, 0) + weight * n
    newest = db.execute(select(Document).where(published()).order_by(desc(Document.published_at)).limit(12)).unique().scalars().all()
    ranked = _published_by_ids(db, sorted(score.items(), key=lambda kv: -kv[1]))
    cover, cover_score = ranked[0] if ranked else ((newest[0], 0) if newest else (None, 0))
    used = {cover.id} if cover else set()

    def first_unused(pairs):
        for doc, value in pairs:
            if doc.id not in used:
                used.add(doc.id)
                return doc, value
        return None, None

    features = []
    doc, _ = first_unused((d, None) for d in newest)
    if doc:
        features.append(_card(doc, label="Newest"))
    doc, v = first_unused(_published_by_ids(db, _counts(db, SearchClickLog.clicked_doc_id, SearchClickLog.timestamp >= month,
                                                        SearchClickLog.event_type == "click")))
    if doc:
        features.append(_card(doc, v, "Most searched"))
    doc, v = first_unused(_published_by_ids(db, _counts(db, DocumentView.document_id, DocumentView.timestamp >= week)))
    if doc:
        features.append(_card(doc, v, "Most read this week"))

    q_lower = func.lower(SearchClickLog.query_string)
    trending = db.execute(select(q_lower, func.count()).where(SearchClickLog.event_type == "search", SearchClickLog.timestamp >= month,
                                                             SearchClickLog.query_string != "", SearchClickLog.results_count > 0)
                          .group_by(q_lower).order_by(desc(func.count())).limit(8)).all()
    sections = []
    for cat in db.execute(select(Category).order_by(Category.name)).scalars():
        docs = db.execute(select(Document).where(published(), Document.category_id == cat.id)
                          .order_by(desc(Document.published_at)).limit(3)).unique().scalars().all()
        if docs:
            sections.append({"category": schemas.CategoryOut.model_validate(cat).model_dump(),
                             "docs": [schemas.DocumentCard.model_validate(d).model_dump(mode="json") for d in docs]})
    return {
        "cover": _card(cover, cover_score, "Cover story") if cover else None,
        "features": features,
        "latest": [schemas.DocumentCard.model_validate(d).model_dump(mode="json") for d in newest if d.id not in used][:6],
        "trending_queries": [{"query": q, "searches": n} for q, n in trending],
        "sections": sections,
    }


@router.get("/attention")
def attention(days: int = Query(7, ge=1, le=90), limit: int = Query(5, ge=1, le=10), db: Session = Depends(get_db)):
    """What readers pay attention to: reading, searching, discussing, rating and liking."""
    from app.models import SearchClickLog
    since = _since(days)
    q_lower = func.lower(SearchClickLog.query_string)
    queries = db.execute(select(q_lower, func.count()).where(SearchClickLog.event_type == "search", SearchClickLog.timestamp >= since,
                                                            SearchClickLog.query_string != "")
                         .group_by(q_lower).order_by(desc(func.count())).limit(limit * 2)).all()
    rated = db.execute(select(Rating.document_id, func.avg(Rating.score)).group_by(Rating.document_id)
                       .having(func.count() >= 2).order_by(desc(func.avg(Rating.score)), desc(func.count())).limit(limit)).all()
    total_views = db.scalar(select(func.count()).select_from(DocumentView).where(DocumentView.timestamp >= since)) or 0
    total_searches = db.scalar(select(func.count()).select_from(SearchClickLog)
                               .where(SearchClickLog.event_type == "search", SearchClickLog.timestamp >= since)) or 0
    return {
        "days": days,
        "totals": {"views": total_views, "searches": total_searches},
        "most_read": [_card(d, v) for d, v in _published_by_ids(db, _counts(db, DocumentView.document_id, DocumentView.timestamp >= since))[:limit]],
        "most_searched": [_card(d, v) for d, v in _published_by_ids(db, _counts(
            db, SearchClickLog.clicked_doc_id, SearchClickLog.timestamp >= since, SearchClickLog.event_type == "click"))[:limit]],
        "trending_queries": [{"query": q, "searches": n} for q, n in queries],
        "most_discussed": [_card(d, v) for d, v in _published_by_ids(db, _counts(db, Comment.document_id, None, Comment.status == "visible"))[:limit]],
        "top_rated": [_card(d, v) for d, v in _published_by_ids(db, [(i, float(a)) for i, a in rated])],
        "most_liked": [_card(d, v) for d, v in _published_by_ids(db, _counts(db, Like.document_id, None))[:limit]],
    }


@router.get("/about")
def about(db: Session = Depends(get_db)):
    """Masthead data for the About page (all numbers computed from the database)."""
    from app.models import SearchClickLog
    counts = dict(db.execute(select(Document.author_id, func.count()).where(published()).group_by(Document.author_id)).all())
    writers = [u for u in db.execute(select(User).where(User.is_active.is_(True), User.id.in_(list(counts) or [-1]))
                                     .order_by(User.full_name)).scalars()]
    return {
        "stats": {
            "articles": db.scalar(select(func.count()).select_from(Document).where(published())) or 0,
            "sections": db.scalar(select(func.count()).select_from(Category)) or 0,
            "readers": db.scalar(select(func.count()).select_from(User)) or 0,
            "comments": db.scalar(select(func.count()).select_from(Comment).where(Comment.status == "visible")) or 0,
            "searches": db.scalar(select(func.count()).select_from(SearchClickLog).where(SearchClickLog.event_type == "search")) or 0,
        },
        "writers": [{**schemas.UserPublic.model_validate(u).model_dump(), "articles": counts.get(u.id, 0)} for u in writers],
        "sections": [c.model_dump() for c in categories(db)],
    }
