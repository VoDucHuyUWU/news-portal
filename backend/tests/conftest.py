"""Test fixtures: a fresh database (SQLite by default, or TEST_DATABASE_URL) and one user per role."""
import os
import sys
import tempfile
from pathlib import Path

_TMP = tempfile.mkdtemp(prefix="news_portal_test_")
os.environ["DATABASE_URL"] = os.getenv("TEST_DATABASE_URL", f"sqlite:///{Path(_TMP, 'test.db').as_posix()}")
os.environ["MEDIA_DIR"] = str(Path(_TMP, "media"))
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import pytest  # noqa: E402
from fastapi.testclient import TestClient  # noqa: E402
from sqlalchemy import select  # noqa: E402

from app.database import Base, SessionLocal, engine, init_db  # noqa: E402
from app.main import app  # noqa: E402
from app.models import Category, Role, User  # noqa: E402
from app.security import hash_password  # noqa: E402

ROLE_USERS = {"super_admin": "boss", "content_manager": "editor", "moderator": "mod",
              "seo_specialist": "seo", "user": "reader"}
PASSWORD = "password123"


@pytest.fixture(scope="session")
def client():
    Base.metadata.drop_all(engine)
    init_db()
    with SessionLocal() as db:
        for role_name, username in ROLE_USERS.items():
            role = db.scalar(select(Role).where(Role.name == role_name))
            db.add(User(username=username, email=f"{username}@test.io", password_hash=hash_password(PASSWORD),
                        full_name=username.title(), role=role))
        db.add(Category(name="Technology", slug="technology", color="#2563eb"))
        db.add(Category(name="Health", slug="health", color="#16a34a"))
        db.commit()
    with TestClient(app) as c:
        yield c
    Base.metadata.drop_all(engine)


@pytest.fixture(scope="session")
def tokens(client):
    out = {}
    for role, username in ROLE_USERS.items():
        r = client.post("/api/auth/login", json={"login": username, "password": PASSWORD})
        assert r.status_code == 200, r.text
        out[role] = {"Authorization": f"Bearer {r.json()['access_token']}"}
    return out


@pytest.fixture(scope="session")
def published_doc(client, tokens):
    body = {"title": "How heat pumps move warmth", "summary": "", "status": "published", "category_id": 1,
            "content": "<p>A heat pump moves heat instead of making it.</p><p>It works like a fridge in reverse.</p>",
            "new_tags": ["Energy", "Homes"]}
    r = client.post("/api/admin/documents", json=body, headers=tokens["content_manager"])
    assert r.status_code == 201, r.text
    return r.json()
