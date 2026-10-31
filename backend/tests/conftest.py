"""Test fixtures: a fresh database per test session, users for every role."""
import os
import sys
import tempfile
from pathlib import Path

_TMP = tempfile.mkdtemp(prefix="news_portal_test_")
os.environ.setdefault("DATABASE_URL", f"sqlite:///{Path(_TMP, 'test.db').as_posix()}")
os.environ["DATA_DIR"] = _TMP
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import pytest  # noqa: E402
from fastapi.testclient import TestClient  # noqa: E402
from sqlalchemy import select  # noqa: E402

from app.database import Base, SessionLocal, engine  # noqa: E402
from app.main import app, init_db  # noqa: E402
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


def login(client, username: str) -> dict:
    r = client.post("/api/auth/login", json={"username": username, "password": PASSWORD})
    assert r.status_code == 200, r.text
    return {"Authorization": f"Bearer {r.json()['access_token']}"}


@pytest.fixture(scope="session")
def auth(client):
    return {name: login(client, name) for name in ROLE_USERS.values()}


@pytest.fixture(scope="session")
def category_ids(client):
    cats = client.get("/api/categories").json()
    return {c["slug"]: c["id"] for c in cats}


def make_doc(client, headers, category_id, title="Heat pumps in cold climates", status="published",
             content=None, tags=("energy", "homes")):
    body = content or ("<p>Heat pumps move heat instead of burning fuel. Modern units keep working "
                       "well below freezing.</p><h2>Why it matters</h2><p>They cut energy bills.</p>")
    r = client.post("/api/admin/documents", headers=headers, json={
        "title": title, "content": body, "category_id": category_id, "tags": list(tags), "status": status})
    assert r.status_code == 201, r.text
    return r.json()
