"""Moderator: comment review queue, reports (flags), spam control."""
from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, Query, Request, status
from sqlalchemy import delete, desc, func, select
from sqlalchemy.orm import Session

from app import schemas
from app.database import get_db
from app.deps import client_ip, require_permission
from app.models import Comment, Document, Report, Setting, User, utcnow
from app.services import mentions_for
from app.utils import audit, get_bool_setting, get_int_setting, get_setting, paginate

router = APIRouter(prefix="/api/admin", tags=["admin: moderation"])


def _report_counts(db: Session, comment_ids: list[int]) -> dict[int, int]:
    if not comment_ids:
        return {}
    return dict(db.execute(select(Report.target_id, func.count()).where(
        Report.target_type == "comment", Report.target_id.in_(comment_ids), Report.status == "open")
        .group_by(Report.target_id)).all())


@router.get("/comments", response_model=schemas.Page[schemas.CommentAdmin])
def list_comments(status_: str | None = Query(None, alias="status", pattern="^(visible|pending|hidden|spam)$"),
                  q: str = "", reported: bool = False, page: int = Query(1, ge=1), page_size: int = Query(20, ge=1, le=100),
                  _: User = Depends(require_permission("comments.moderate")), db: Session = Depends(get_db)):
    stmt = select(Comment).order_by(desc(Comment.created_at))
    if status_:
        stmt = stmt.where(Comment.status == status_)
    if q:
        stmt = stmt.where(Comment.content.ilike(f"%{q}%"))
    if reported:
        stmt = stmt.where(Comment.id.in_(select(Report.target_id).where(Report.target_type == "comment",
                                                                        Report.status == "open")))
    result = paginate(db, stmt, page, page_size)
    ids = [c.id for c in result["items"]]
    mentions, reports = mentions_for(db, ids), _report_counts(db, ids)
    result["items"] = [schemas.CommentAdmin(
        id=c.id, document_id=c.document_id, parent_id=c.parent_id, content=c.content, status=c.status,
        created_at=c.created_at, user=schemas.UserPublic.model_validate(c.user), mentions=mentions.get(c.id, []),
        flag_reason=c.flag_reason, document_title=c.document.title, document_slug=c.document.slug,
        report_count=reports.get(c.id, 0)) for c in result["items"]]
    return result


@router.patch("/comments/{comment_id}")
def moderate_comment(comment_id: int, body: schemas.CommentModerateIn, request: Request,
                     actor: User = Depends(require_permission("comments.moderate")), db: Session = Depends(get_db)):
    comment = db.get(Comment, comment_id)
    if comment is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Comment not found")
    before = comment.status
    comment.status = body.status
    if body.status == "visible":
        comment.flag_reason = ""
    audit(db, actor.id, "comment.moderate", "comment", comment.id, f"{before} -> {body.status}", client_ip(request))
    db.commit()
    return {"id": comment.id, "status": comment.status}


@router.delete("/comments/{comment_id}", status_code=204)
def delete_comment(comment_id: int, request: Request, actor: User = Depends(require_permission("comments.moderate")),
                   db: Session = Depends(get_db)):
    comment = db.get(Comment, comment_id)
    if comment is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Comment not found")
    audit(db, actor.id, "comment.delete", "comment", comment.id, comment.content[:120], client_ip(request))
    db.delete(comment)
    db.commit()


@router.post("/comments/purge-spam")
def purge_spam(request: Request, actor: User = Depends(require_permission("comments.moderate")),
               db: Session = Depends(get_db)):
    deleted = db.execute(delete(Comment).where(Comment.status == "spam")).rowcount or 0
    audit(db, actor.id, "comment.purge_spam", "comment", "", f"{deleted} spam comments deleted", client_ip(request))
    db.commit()
    return {"deleted": deleted}


# ------------------------------------------------------------------ reports
def _target_preview(db: Session, report: Report) -> tuple[str, str]:
    if report.target_type == "comment":
        c = db.get(Comment, report.target_id)
        if c is None:
            return "(comment deleted)", ""
        return f"{c.user.username}: {c.content[:200]} [{c.status}]", f"/article/{c.document.slug}#comment-{c.id}"
    d = db.get(Document, report.target_id)
    return ((d.title + f" [{d.status}]"), f"/article/{d.slug}") if d else ("(article deleted)", "")


@router.get("/reports", response_model=schemas.Page[schemas.ReportOut])
def list_reports(status_: str | None = Query("open", alias="status", pattern="^(open|resolved|dismissed)$"),
                 page: int = Query(1, ge=1), page_size: int = Query(20, ge=1, le=100),
                 _: User = Depends(require_permission("reports.handle")), db: Session = Depends(get_db)):
    stmt = select(Report).order_by(desc(Report.created_at))
    if status_:
        stmt = stmt.where(Report.status == status_)
    result = paginate(db, stmt, page, page_size)
    items = []
    for r in result["items"]:
        preview, link = _target_preview(db, r)
        items.append(schemas.ReportOut(**schemas.ReportOut.model_validate(r).model_dump(exclude={"target_preview", "target_link"}),
                                       target_preview=preview, target_link=link))
    result["items"] = items
    return result


@router.patch("/reports/{report_id}")
def handle_report(report_id: int, body: schemas.ReportHandleIn, request: Request,
                  actor: User = Depends(require_permission("reports.handle")), db: Session = Depends(get_db)):
    report = db.get(Report, report_id)
    if report is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Report not found")
    if body.action in ("hide", "spam"):
        if report.target_type != "comment":
            raise HTTPException(status.HTTP_400_BAD_REQUEST, "Hide/spam actions apply to comments only")
        comment = db.get(Comment, report.target_id)
        if comment is not None:
            comment.status = "hidden" if body.action == "hide" else "spam"
    elif body.action == "unpublish":
        if report.target_type != "document":
            raise HTTPException(status.HTTP_400_BAD_REQUEST, "Unpublish applies to articles only")
        if "documents.publish" not in actor.permission_codes:
            raise HTTPException(status.HTTP_403_FORBIDDEN, "Missing permission: documents.publish")
        doc = db.get(Document, report.target_id)
        if doc is not None:
            doc.status = "draft"
    report.status, report.resolution_note = body.status, body.note
    report.handled_by_id, report.handled_at = actor.id, utcnow()
    audit(db, actor.id, "report.handle", "report", report.id, f"{body.status}, action={body.action}", client_ip(request))
    db.commit()
    return {"id": report.id, "status": report.status}


# ------------------------------------------------------------------ spam rules
@router.get("/spam-rules", response_model=schemas.SpamRulesIn)
def get_spam_rules(_: User = Depends(require_permission("comments.moderate")), db: Session = Depends(get_db)):
    return schemas.SpamRulesIn(spam_keywords=get_setting(db, "spam_keywords"),
                               max_links_per_comment=get_int_setting(db, "max_links_per_comment", 2),
                               comment_rate_limit_per_minute=get_int_setting(db, "comment_rate_limit_per_minute", 5),
                               comments_require_approval=get_bool_setting(db, "comments_require_approval"))


@router.put("/spam-rules", response_model=schemas.SpamRulesIn)
def put_spam_rules(body: schemas.SpamRulesIn, request: Request,
                   actor: User = Depends(require_permission("comments.moderate")), db: Session = Depends(get_db)):
    values = {"spam_keywords": ", ".join(k.strip() for k in body.spam_keywords.split(",") if k.strip()),
              "max_links_per_comment": str(body.max_links_per_comment),
              "comment_rate_limit_per_minute": str(body.comment_rate_limit_per_minute),
              "comments_require_approval": "true" if body.comments_require_approval else "false"}
    for key, value in values.items():
        row = db.get(Setting, key)
        if row is None:
            db.add(Setting(key=key, value=value))
        else:
            row.value = value
    audit(db, actor.id, "spam_rules.update", "settings", "", ", ".join(values), client_ip(request))
    db.commit()
    return get_spam_rules(actor, db)
