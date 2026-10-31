"""FastAPI application: REST API under /api, uploaded media under /media, React build at /."""
from __future__ import annotations

import mimetypes
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse, JSONResponse
from fastapi.staticfiles import StaticFiles

from app.config import settings
from app.database import SessionLocal, init_db
from app.routers import admin_content, admin_moderation, admin_seo, admin_system, auth, public, search, users


# Windows can map .svg/.js to the wrong type via the registry; browsers then refuse to show the file.
mimetypes.add_type("image/svg+xml", ".svg")
mimetypes.add_type("text/javascript", ".js")
mimetypes.add_type("text/css", ".css")


@asynccontextmanager
async def lifespan(_: FastAPI):
    init_db()
    settings.media_dir.mkdir(parents=True, exist_ok=True)
    from seed.covers import ensure_covers  # generated artwork, refreshed when its version changes

    with SessionLocal() as db:
        ensure_covers(db)
    yield


app = FastAPI(title="Margin News Portal API", version="1.0.0", lifespan=lifespan,
              description="News & Digital Magazine Portal: CRUD, JWT auth, RBAC, search/click logging.")
app.add_middleware(CORSMiddleware, allow_origins=list(settings.cors_origins), allow_credentials=True,
                   allow_methods=["*"], allow_headers=["*"])
for r in (auth.router, users.router, public.router, search.router, admin_system.router, admin_content.router,
          admin_moderation.router, admin_seo.router):
    app.include_router(r)

settings.media_dir.mkdir(parents=True, exist_ok=True)
app.mount("/media", StaticFiles(directory=settings.media_dir), name="media")

if (settings.frontend_dist / "assets").exists():
    app.mount("/assets", StaticFiles(directory=settings.frontend_dist / "assets"), name="assets")


@app.get("/{full_path:path}", include_in_schema=False)
def spa(full_path: str):
    """Serve the built React app; unknown /api paths return JSON 404."""
    if full_path.startswith("api/"):
        return JSONResponse({"detail": "Not Found"}, status_code=404)
    candidate = settings.frontend_dist / full_path
    if full_path and candidate.is_file():
        return FileResponse(candidate)
    index = settings.frontend_dist / "index.html"
    if index.exists():
        return FileResponse(index)
    return JSONResponse({"message": "API is running. Frontend not built yet: see README (npm run build).",
                         "docs": "/docs"})
