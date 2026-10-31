"""Moderator: comment review, flags/reports, spam control."""
from __future__ import annotations

from typing import Literal

from fastapi import APIRouter, Depends, HTTPException, Query, Request, status
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app import schemas
from app.config import MAX_PAGE_SIZE
from app.database import get_db, utcnow
from app.deps import require_permission
from app.models import Comment, Document, Report, User
from app.serializers import comment_admin_out, paginate
from app.services import audit, get_setting, matches_spam, set_setting

router = APIRouter(prefix="/api/admin/moderation", tags=["moderation"])


@router.get("/comments", response_model=schemas.Page)
def list_comments(status_: Literal["visible", "pending", "hidden", "spam"] | None = Query("pending", alias="status"),
                  q: str | None = None, page: int = Query(1, ge=1), page_size: int = Query(20, ge=1, le=MAX_PAGE_SIZE),
                  _: User = Depends(require_permission("comment.moderate")), db: Session = Depends(get_db)):
    query = select(Comment)
    if status_:
        query = query.where(Comment.status == status_)
    if q:
        query = query.where(Comment.content.ilike(f"%{q}%"))
    total = db.scalar(select(func.count()).select_from(query.subquery())) or 0
    rows = db.scalars(query.order_by(Comment.created_at.desc()).offset((page - 1) * page_size)
                      .limit(page_size)).unique().all()
    items = []
    for c in rows:
        out = comment_admin_out(c).model_dump(mode="json")
        out["spam_match"] = matches_spam(db, c.content)
        out["author_muted"] = c.user.is_muted
        items.append(out)
    return paginate(total, page, page_size, items)


@router.put("/comments/{comment_id}/status", response_model=schemas.CommentAdminOut)
def set_comment_status(comment_id: int, data: schemas.CommentStatusIn, request: Request,
                       user: User = Depends(require_permission("comment.moderate")), db: Session = Depends(get_db)):
    comment = db.get(Comment, comment_id)
    if comment is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Comment not found.")
    old = comment.status
    comment.status, comment.moderated_by, comment.moderated_at = data.status, user.id, utcnow()
    audit(db, user, "comment.moderate", "comment", comment.id, f"{old} -> {data.status}", request)
    return comment_admin_out(comment)


@router.delete("/comments/{comment_id}", status_code=204)
def delete_comment(comment_id: int, request: Request, user: User = Depends(require_permission("comment.moderate")),
                   db: Session = Depends(get_db)):
    comment = db.get(Comment, comment_id)
    if comment is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Comment not found.")
    preview = comment.content[:120]
    db.delete(comment)
    audit(db, user, "comment.delete", "comment", comment_id, preview, request)


# ------------------------------------------------------------------- reports
def _report_out(db: Session, report: Report) -> schemas.ReportOut:
    preview, link = "(deleted)", ""
    if report.target_type == "comment":
        c = db.get(Comment, report.target_id)
        if c:
            preview, link = f"@{c.user.username}: {c.content[:200]} [{c.status}]", f"/article/{c.document.slug}#comment-{c.id}"
    else:
        d = db.get(Document, report.target_id)
        if d:
            preview, link = f"{d.title} [{d.status}]", f"/article/{d.slug}"
    base = schemas.ReportOut.model_validate(report).model_dump(exclude={"target_preview", "target_link"})
    return schemas.ReportOut(**base, target_preview=preview, target_link=link)


@router.get("/reports", response_model=schemas.Page)
def list_reports(status_: Literal["open", "resolved", "dismissed"] | None = Query("open", alias="status"),
                 page: int = Query(1, ge=1), page_size: int = Query(20, ge=1, le=MAX_PAGE_SIZE),
                 _: User = Depends(require_permission("report.handle")), db: Session = Depends(get_db)):
    query = select(Report)
    if status_:
        query = query.where(Report.status == status_)
    total = db.scalar(select(func.count()).select_from(query.subquery())) or 0
    rows = db.scalars(query.order_by(Report.created_at.desc()).offset((page - 1) * page_size).limit(page_size)).all()
    return paginate(total, page, page_size, [_report_out(db, r) for r in rows])


@router.put("/reports/{report_id}", response_model=schemas.ReportOut)
def resolve_report(report_id: int, data: schemas.ReportResolve, request: Request,
                   user: User = Depends(require_permission("report.handle")), db: Session = Depends(get_db)):
    report = db.get(Report, report_id)
    if report is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Report not found.")
    if data.hide_target:
        if report.target_type == "comment":
            comment = db.get(Comment, report.target_id)
            if comment:
                comment.status, comment.moderated_by, comment.moderated_at = "hidden", user.id, utcnow()
        else:
            raise HTTPException(status.HTTP_400_BAD_REQUEST,
                                "Moderators cannot unpublish articles; ask a Content Manager.")
    report.status, report.resolution_note = data.status, data.note.strip()
    report.handled_by, report.handled_at = user.id, utcnow()
    audit(db, user, f"report.{data.status}", report.target_type, report.target_id,
          data.note + (" (target hidden)" if data.hide_target else ""), request)
    return _report_out(db, report)


# -------------------------------------------------------------- spam control
@router.get("/spam-keywords")
def get_spam_keywords(_: User = Depends(require_permission("spam.manage")), db: Session = Depends(get_db)):
    return {"keywords": get_setting(db, "spam_keywords") or []}


@router.put("/spam-keywords")
def update_spam_keywords(data: schemas.SpamKeywordsIn, request: Request,
                         user: User = Depends(require_permission("spam.manage")), db: Session = Depends(get_db)):
    keywords = sorted({k.strip().lower() for k in data.keywords if k.strip()})
    set_setting(db, "spam_keywords", keywords, user)
    audit(db, user, "spam.keywords_update", "setting", "spam_keywords", f"{len(keywords)} keywords", request)
    return {"keywords": keywords}


@router.put("/users/{user_id}/mute")
def mute_user(user_id: int, muted: bool, request: Request, user: User = Depends(require_permission("spam.manage")),
              db: Session = Depends(get_db)):
    target = db.get(User, user_id)
    if target is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "User not found.")
    if target.id == user.id:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "You cannot mute yourself.")
    target.is_muted = muted
    audit(db, user, "user.mute" if muted else "user.unmute", "user", target.id, f"@{target.username}", request)
    return {"id": target.id, "username": target.username, "is_muted": target.is_muted}
