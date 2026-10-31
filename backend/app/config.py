"""Application settings, read from environment variables (with safe local defaults)."""
from __future__ import annotations

import os
from dataclasses import dataclass, field
from pathlib import Path

BACKEND_DIR = Path(__file__).resolve().parent.parent
PROJECT_DIR = BACKEND_DIR.parent


def _load_dotenv() -> None:
    """Minimal .env loader (KEY=VALUE lines) so no extra dependency is needed."""
    for env_file in (PROJECT_DIR / ".env", BACKEND_DIR / ".env"):
        if env_file.exists():
            for line in env_file.read_text(encoding="utf-8").splitlines():
                line = line.strip()
                if line and not line.startswith("#") and "=" in line:
                    key, value = line.split("=", 1)
                    os.environ.setdefault(key.strip(), value.strip().strip('"').strip("'"))


_load_dotenv()


@dataclass(frozen=True)
class Settings:
    # PostgreSQL example: postgresql+psycopg://news:news@localhost:5432/news_portal
    database_url: str = field(default_factory=lambda: os.getenv(
        "DATABASE_URL", f"sqlite:///{(BACKEND_DIR / 'news_portal.db').as_posix()}"))
    secret_key: str = field(default_factory=lambda: os.getenv("SECRET_KEY", "dev-only-change-me-in-production"))
    access_token_minutes: int = field(default_factory=lambda: int(os.getenv("ACCESS_TOKEN_MINUTES", "1440")))
    media_dir: Path = field(default_factory=lambda: Path(os.getenv("MEDIA_DIR", str(BACKEND_DIR / "media"))))
    frontend_dist: Path = BACKEND_DIR / "frontend_dist"
    cors_origins: tuple[str, ...] = ("http://localhost:5173", "http://127.0.0.1:5173")
    max_upload_mb: int = 5


settings = Settings()
