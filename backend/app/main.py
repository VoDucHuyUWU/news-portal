"""FastAPI application: REST API under /api, responsive frontend served from /."""
from __future__ import annotations

import html
from contextlib import asynccontextmanager

from fastapi import Depends, FastAPI, HTTPException
from fastapi.responses import FileResponse, HTMLResponse
from fastapi.staticfiles import StaticFiles
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.config import FRONTEND_DIR, UPLOAD_DIR
from app.database import Base, SessionLocal, engine, get_db
from app.models import Document
from app.permissions import ensure_rbac
from app.routers import ROUTERS
from app.services import ensure_settings, get_setting


def init_db() -> None:
    """Create tables, roles/permissions and default settings (idempotent)."""
    Base.metadata.create_all(engine)
    with SessionLocal() as db:
        ensure_rbac(db)
        ensure_settings(db)


@asynccontextmanager
async def lifespan(_app: FastAPI):
    init_db()
    yield


app = FastAPI(title="Lantern News Portal API", version="1.0.0", lifespan=lifespan,
              description="REST API for the News & Digital Magazine Portal (Phase 1). "
                          "Interactive docs at /docs.")
for router in ROUTERS:
    app.include_router(router)

app.mount("/uploads", StaticFiles(directory=UPLOAD_DIR), name="uploads")


@app.get("/api/health", tags=["system"])
def health():
    return {"status": "ok"}


def _page(name: str) -> FileResponse:
    return FileResponse(FRONTEND_DIR / name)


@app.get("/", include_in_schema=False)
def home():
    return _page("index.html")


@app.get("/article/{slug}", include_in_schema=False, response_class=HTMLResponse)
def article_page(slug: str, db: Session = Depends(get_db)):
    """Serve the article page with SEO metadata rendered server-side (visible to crawlers)."""
    doc = db.scalar(select(Document).where(Document.slug == slug, Document.status == "published"))
    template = (FRONTEND_DIR / "article.html").read_text(encoding="utf-8")
    site = get_setting(db, "site_name")
    if doc is None:
        raise HTTPException(404, "Article not found")
    seo = doc.seo
    title = (seo.meta_title if seo and seo.meta_title else doc.title)
    description = (seo.meta_description if seo and seo.meta_description else doc.summary)
    keywords = seo.keywords if seo else ""
    esc = lambda s: html.escape(s or "", quote=True)  # noqa: E731
    head = (f"<title>{esc(title)} | {esc(site)}</title>\n"
            f'<meta name="description" content="{esc(description)}">\n'
            f'<meta name="keywords" content="{esc(keywords)}">\n'
            f'<meta property="og:title" content="{esc(title)}">\n'
            f'<meta property="og:description" content="{esc(description)}">\n'
            f'<meta property="og:image" content="{esc(doc.cover_image_url)}">\n'
            f'<meta property="og:type" content="article">')
    return template.replace("<!--SEO_HEAD-->", head)


app.mount("/", StaticFiles(directory=FRONTEND_DIR, html=True), name="frontend")
