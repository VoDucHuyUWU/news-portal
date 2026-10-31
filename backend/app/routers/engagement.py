"""User engagement: comments (with @mentions), likes, ratings and reports."""
from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, Request, status
from sqlalchemy import func, or_, select
from sqlalchemy.orm import Session

from app import schemas
from app.database import get_db, utcnow
from app.deps import get_current_user, get_current_user_optional
from app.models import Comment, Document, Like, Rating, Report, User
from app.serializers import comment_out
from app.services import audit, find_mentioned_users, get_setting, matches_spam

router = APIRouter(prefix="/api", tags=["engagement"])


def _published(db: Session, doc_id: int) -> Document:
    doc = db.get(Document, doc_id)
    if doc is None or doc.status != "published":
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Article not found.")
    return doc


def _initial_status(db: Session, text: str) -> str:
    if matches_spam(db, text):
        return "pending"  # held for a moderator
    return "pending" if get_setting(db, "comments_require_approval") else "visible"


# ------------------------------------------------------------------ comments
@router.get("/documents/{doc_id}/comments", response_model=list[schemas.CommentOut])
def list_comments(doc_id: int, db: Session = Depends(get_db), viewer: User | None = Depends(get_current_user_optional)):
    """Visible comments, plus the viewer's own comments that are awaiting review."""
    _published(db, doc_id)
    cond = Comment.status == "visible"
    if viewer is not None:
        cond = or_(cond, (Comment.user_id == viewer.id) & (Comment.status == "pending"))
    rows = db.scalars(select(Comment).where(Comment.document_id == doc_id, cond)
                      .order_by(Comment.created_at.asc())).unique().all()
    return [comment_out(c) for c in rows]


@router.post("/documents/{doc_id}/comments", response_model=schemas.CommentOut, status_code=201)
def add_comment(doc_id: int, data: schemas.CommentIn, request: Request, user: User = Depends(get_current_user),
                db: Session = Depends(get_db)):
    _published(db, doc_id)
    if user.is_muted:
        raise HTTPException(status.HTTP_403_FORBIDDEN, "Your account has been muted by a moderator.")
    if data.parent_id is not None:
        parent = db.get(Comment, data.parent_id)
        if parent is None or parent.document_id != doc_id:
            raise HTTPException(status.HTTP_400_BAD_REQUEST, "Invalid parent comment.")
    text = data.content.strip()
    if not text:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "Comment is empty.")
    comment = Comment(document_id=doc_id, user_id=user.id, parent_id=data.parent_id, content=text,
                      status=_initial_status(db, text))
    comment.mentions = find_mentioned_users(db, text, exclude_user_id=user.id)
    db.add(comment)
    db.flush()
    flag = matches_spam(db, text)
    audit(db, user, "comment.create", "comment", comment.id,
          f"status={comment.status}" + (f", spam match: {flag}" if flag else ""), request)
    db.refresh(comment)
    return comment_out(comment)


@router.put("/comments/{comment_id}", response_model=schemas.CommentOut)
def edit_comment(comment_id: int, data: schemas.CommentIn, request: Request, user: User = Depends(get_current_user),
                 db: Session = Depends(get_db)):
    comment = db.get(Comment, comment_id)
    if comment is None or comment.user_id != user.id or comment.status in ("hidden", "spam"):
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Comment not found.")
    text = data.content.strip()
    comment.content, comment.updated_at = text, utcnow()
    comment.status = _initial_status(db, text)
    comment.mentions = find_mentioned_users(db, text, exclude_user_id=user.id)
    audit(db, user, "comment.update", "comment", comment.id, f"status={comment.status}", request)
    db.refresh(comment)
    return comment_out(comment)


@router.delete("/comments/{comment_id}", status_code=204)
def delete_own_comment(comment_id: int, request: Request, user: User = Depends(get_current_user),
                       db: Session = Depends(get_db)):
    comment = db.get(Comment, comment_id)
    if comment is None or comment.user_id != user.id:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Comment not found.")
    db.delete(comment)
    audit(db, user, "comment.delete_own", "comment", comment_id, "", request)


# ------------------------------------------------------------ likes / ratings
def _like_count(db: Session, doc_id: int) -> int:
    return db.scalar(select(func.count()).select_from(Like).where(Like.document_id == doc_id)) or 0


@router.post("/documents/{doc_id}/like")
def toggle_like(doc_id: int, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    _published(db, doc_id)
    existing = db.get(Like, (user.id, doc_id))
    if existing:
        db.delete(existing)
        liked = False
    else:
        db.add(Like(user_id=user.id, document_id=doc_id))
        liked = True
    db.commit()
    return {"liked": liked, "like_count": _like_count(db, doc_id)}


def _rating_summary(db: Session, doc_id: int, user: User) -> dict:
    avg, count = db.execute(select(func.avg(Rating.score), func.count()).where(Rating.document_id == doc_id)).one()
    mine = db.get(Rating, (user.id, doc_id))
    return {"my_rating": mine.score if mine else None, "rating_avg": round(float(avg), 2) if avg else None,
            "rating_count": count or 0}


@router.put("/documents/{doc_id}/rating")
def rate(doc_id: int, data: schemas.RatingIn, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    _published(db, doc_id)
    rating = db.get(Rating, (user.id, doc_id))
    if rating:
        rating.score = data.score
    else:
        db.add(Rating(user_id=user.id, document_id=doc_id, score=data.score))
    db.commit()
    return _rating_summary(db, doc_id, user)


@router.delete("/documents/{doc_id}/rating")
def remove_rating(doc_id: int, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    rating = db.get(Rating, (user.id, doc_id))
    if rating:
        db.delete(rating)
        db.commit()
    return _rating_summary(db, doc_id, user)


# ------------------------------------------------------------------- reports
@router.post("/reports", status_code=201)
def create_report(data: schemas.ReportIn, request: Request, user: User = Depends(get_current_user),
                  db: Session = Depends(get_db)):
    """Flag a comment or an article for moderators."""
    target = db.get(Comment if data.target_type == "comment" else Document, data.target_id)
    if target is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Reported item not found.")
    duplicate = db.scalar(select(Report).where(Report.reporter_id == user.id, Report.target_type == data.target_type,
                                               Report.target_id == data.target_id, Report.status == "open"))
    if duplicate:
        return {"id": duplicate.id, "status": "already_reported"}
    report = Report(reporter_id=user.id, target_type=data.target_type, target_id=data.target_id,
                    reason=data.reason.strip())
    db.add(report)
    db.flush()
    audit(db, user, "report.create", data.target_type, data.target_id, data.reason[:200], request)
    return {"id": report.id, "status": "open"}
