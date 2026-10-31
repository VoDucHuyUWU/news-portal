"""Business logic shared by several routers (serialisation, spam control, engagement stats)."""
from __future__ import annotations

import re
from datetime import timedelta

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app import schemas
from app.models import Comment, CommentMention, Document, Like, Rating, User, utcnow
from app.utils import MENTION_RE, get_bool_setting, get_int_setting, get_setting

URL_RE = re.compile(r"https?://|www\.", re.I)


def user_me(user: User) -> schemas.UserMe:
    return schemas.UserMe(
        id=user.id, username=user.username, full_name=user.full_name, avatar_url=user.avatar_url,
        bio=user.bio, email=user.email, role=schemas.RoleOut.model_validate(user.role),
        permissions=sorted(user.permission_codes), created_at=user.created_at)


def engagement(db: Session, document_id: int, user: User | None) -> schemas.EngagementOut:
    like_count = db.scalar(select(func.count()).select_from(Like).where(Like.document_id == document_id)) or 0
    avg, count = db.execute(select(func.avg(Rating.score), func.count()).where(Rating.document_id == document_id)).one()
    liked = my_rating = None
    if user is not None:
        liked = db.get(Like, (user.id, document_id)) is not None
        r = db.get(Rating, (user.id, document_id))
        my_rating = r.score if r else None
    return schemas.EngagementOut(like_count=like_count, liked_by_me=bool(liked),
                                 rating_avg=round(float(avg), 2) if avg is not None else None,
                                 rating_count=count or 0, my_rating=my_rating)


def document_detail(db: Session, doc: Document, user: User | None) -> schemas.DocumentDetail:
    eng = engagement(db, doc.id, user)
    comment_count = db.scalar(select(func.count()).select_from(Comment)
                              .where(Comment.document_id == doc.id, Comment.status == "visible")) or 0
    base = schemas.DocumentCard.model_validate(doc).model_dump()
    return schemas.DocumentDetail(
        **base, content=doc.content, seo=schemas.SeoOut.model_validate(doc.seo) if doc.seo else None,
        comment_count=comment_count, reading_minutes=max(1, round(len(doc.content_text.split()) / 200)),
        **eng.model_dump())


def mentions_for(db: Session, comment_ids: list[int]) -> dict[int, list[str]]:
    if not comment_ids:
        return {}
    rows = db.execute(select(CommentMention.comment_id, User.username)
                      .join(User, User.id == CommentMention.mentioned_user_id)
                      .where(CommentMention.comment_id.in_(comment_ids))).all()
    out: dict[int, list[str]] = {}
    for cid, username in rows:
        out.setdefault(cid, []).append(username)
    return out


def comments_out(db: Session, comments: list[Comment]) -> list[schemas.CommentOut]:
    mentions = mentions_for(db, [c.id for c in comments])
    return [schemas.CommentOut(id=c.id, document_id=c.document_id, parent_id=c.parent_id, content=c.content,
                               status=c.status, created_at=c.created_at,
                               user=schemas.UserPublic.model_validate(c.user), mentions=mentions.get(c.id, []))
            for c in comments]


def spam_reason(db: Session, text: str) -> str:
    """Return why a comment looks like spam ('' if it does not)."""
    lowered = text.lower()
    keywords = [k.strip().lower() for k in get_setting(db, "spam_keywords").split(",") if k.strip()]
    hits = [k for k in keywords if k in lowered]
    if hits:
        return f"contains spam keyword(s): {', '.join(hits[:3])}"
    max_links = get_int_setting(db, "max_links_per_comment", 2)
    if len(URL_RE.findall(text)) > max_links:
        return f"more than {max_links} links"
    if len(text) > 30 and sum(ch.isupper() for ch in text) / max(1, sum(ch.isalpha() for ch in text)) > 0.7:
        return "mostly capital letters"
    return ""


def comment_rate_exceeded(db: Session, user_id: int) -> bool:
    limit = get_int_setting(db, "comment_rate_limit_per_minute", 5)
    since = utcnow() - timedelta(minutes=1)
    recent = db.scalar(select(func.count()).select_from(Comment)
                       .where(Comment.user_id == user_id, Comment.created_at >= since)) or 0
    return recent >= limit


def initial_comment_status(db: Session, text: str, author: User) -> tuple[str, str]:
    """(status, flag_reason) for a new comment. Staff comments are trusted."""
    if author.permission_codes:
        return "visible", ""
    reason = spam_reason(db, text)
    if reason:
        return "pending", f"Auto-flagged: {reason}"
    if get_bool_setting(db, "comments_require_approval"):
        return "pending", "Approval required by site settings"
    return "visible", ""


def save_mentions(db: Session, comment: Comment) -> list[str]:
    names = {m.lower() for m in MENTION_RE.findall(comment.content)}
    if not names:
        return []
    users = db.execute(select(User).where(func.lower(User.username).in_(names), User.is_active.is_(True))).scalars().all()
    for u in users:
        if u.id != comment.user_id:
            db.add(CommentMention(comment_id=comment.id, mentioned_user_id=u.id))
    return [u.username for u in users if u.id != comment.user_id]
