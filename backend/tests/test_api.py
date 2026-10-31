"""End-to-end API tests: auth, RBAC, CRUD, engagement, search logging, moderation, admin."""
from sqlalchemy import select

from app.database import SessionLocal
from app.models import SearchClickLog
from tests.conftest import login, make_doc


# ------------------------------------------------------------------ auth / profile
def test_register_login_profile(client):
    r = client.post("/api/auth/register", json={"username": "New_Reader", "email": "nr@test.io",
                                                "password": "password123", "full_name": "New Reader"})
    assert r.status_code == 201 and r.json()["user"]["username"] == "new_reader"
    assert r.json()["user"]["role"] == "user" and r.json()["user"]["permissions"] == []
    assert client.post("/api/auth/register", json={"username": "new_reader", "email": "x@test.io",
                                                   "password": "password123"}).status_code == 409
    assert client.post("/api/auth/login", json={"username": "nr@test.io", "password": "wrong"}).status_code == 401
    h = login(client, "nr@test.io".replace("nr@test.io", "new_reader"))
    r = client.put("/api/users/me", headers=h, json={"bio": "I read a lot.", "full_name": "N. Reader"})
    assert r.json()["bio"] == "I read a lot."
    assert client.post("/api/users/me/password", headers=h, json={"current_password": "bad",
                                                                  "new_password": "newpassword1"}).status_code == 400
    assert client.post("/api/users/me/password", headers=h, json={"current_password": "password123",
                                                                  "new_password": "newpassword1"}).status_code == 204
    assert client.get("/api/users/new_reader").json()["full_name"] == "N. Reader"
    assert client.get("/api/auth/me").status_code == 401


# ------------------------------------------------------------------------- RBAC
def test_rbac_blocks_wrong_roles(client, auth, category_ids):
    payload = {"title": "Not allowed", "content": "<p>Some content long enough.</p>",
               "category_id": category_ids["technology"]}
    for who in ("mod", "seo", "reader"):
        assert client.post("/api/admin/documents", headers=auth[who], json=payload).status_code == 403
    assert client.post("/api/admin/documents", json=payload).status_code == 401
    assert client.get("/api/admin/users", headers=auth["editor"]).status_code == 403
    assert client.get("/api/admin/logs", headers=auth["mod"]).status_code == 403
    assert client.get("/api/admin/analytics", headers=auth["editor"]).status_code == 403
    assert client.get("/api/admin/moderation/comments", headers=auth["seo"]).status_code == 403
    assert client.put("/api/admin/settings", headers=auth["seo"], json={"site_name": "X"}).status_code == 403
    for who, ok in (("boss", 200), ("seo", 200), ("reader", 403)):
        assert client.get("/api/admin/analytics", headers=auth[who]).status_code == ok
    assert client.get("/api/admin/me", headers=auth["reader"]).json()["can_access_admin"] is False
    assert client.get("/api/admin/me", headers=auth["mod"]).json()["can_access_admin"] is True


# ------------------------------------------------------------------ documents CRUD
def test_document_crud_and_publish_visibility(client, auth, category_ids):
    doc = make_doc(client, auth["editor"], category_ids["technology"], title="Draft about batteries",
                   status="draft", content="<p>Solid-state batteries <script>alert(1)</script>store energy.</p>")
    assert "<script>" not in doc["content"] and "Solid-state batteries" in doc["content_text"]
    assert doc["summary"].startswith("Solid-state batteries")
    assert client.get(f"/api/documents/{doc['slug']}").status_code == 404  # draft is hidden
    assert client.post(f"/api/admin/documents/{doc['id']}/publish", headers=auth["mod"]).status_code == 403
    r = client.post(f"/api/admin/documents/{doc['id']}/publish", headers=auth["editor"])
    assert r.json()["status"] == "published" and r.json()["published_at"]
    detail = client.get(f"/api/documents/{doc['slug']}").json()
    assert detail["author"]["username"] == "editor" and detail["views_count"] == 1
    assert {t["name"] for t in detail["tags"]} == {"energy", "homes"}
    upd = client.put(f"/api/admin/documents/{doc['id']}", headers=auth["editor"], json={
        "title": "Solid-state batteries explained", "content": "<p>Updated text about batteries and cars.</p>",
        "category_id": category_ids["technology"], "tags": ["energy"], "status": "published"}).json()
    assert upd["slug"] == "solid-state-batteries-explained" and [t["name"] for t in upd["tags"]] == ["energy"]
    listing = client.get("/api/documents", params={"page_size": 50}).json()
    assert any(d["id"] == doc["id"] for d in listing["items"]) and listing["total"] >= 1
    assert client.post(f"/api/admin/documents/{doc['id']}/unpublish", headers=auth["editor"]).json()["status"] == "draft"
    assert client.delete(f"/api/admin/documents/{doc['id']}", headers=auth["mod"]).status_code == 403
    assert client.delete(f"/api/admin/documents/{doc['id']}", headers=auth["editor"]).status_code == 204
    assert client.get(f"/api/admin/documents/{doc['id']}", headers=auth["editor"]).status_code == 404


def test_taxonomy_crud(client, auth):
    r = client.post("/api/admin/categories", headers=auth["editor"], json={"name": "Space", "color": "#112233"})
    assert r.status_code == 201 and r.json()["slug"] == "space"
    cid = r.json()["id"]
    assert client.put(f"/api/admin/categories/{cid}", headers=auth["editor"],
                      json={"name": "Space & Astronomy", "color": "#112233"}).json()["slug"] == "space-astronomy"
    assert client.post("/api/admin/categories", headers=auth["seo"], json={"name": "Nope"}).status_code == 403
    t = client.post("/api/admin/tags", headers=auth["editor"], json={"name": "Mars"}).json()
    assert client.delete(f"/api/admin/tags/{t['id']}", headers=auth["editor"]).status_code == 204
    assert client.delete(f"/api/admin/categories/{cid}", headers=auth["editor"]).status_code == 204


def test_seo_specialist_edits_metadata(client, auth, category_ids):
    doc = make_doc(client, auth["editor"], category_ids["health"], title="Sleep and memory")
    r = client.put(f"/api/admin/documents/{doc['id']}/seo", headers=auth["seo"], json={
        "meta_title": "How sleep helps memory", "meta_description": "What happens in the brain at night.",
        "keywords": "sleep, memory", "cover_image_alt": "A person asleep"})
    assert r.status_code == 200 and r.json()["seo"]["meta_title"] == "How sleep helps memory"
    assert client.put(f"/api/admin/documents/{doc['id']}/seo", headers=auth["editor"], json={}).status_code == 403
    page = client.get(f"/article/{doc['slug']}")
    assert page.status_code == 200 and "How sleep helps memory" in page.text and "A person" not in page.text


# --------------------------------------------------------------------- engagement
def test_comments_mentions_likes_ratings_reports(client, auth, category_ids):
    doc = make_doc(client, auth["editor"], category_ids["health"], title="Walking after meals")
    c = client.post(f"/api/documents/{doc['id']}/comments", headers=auth["reader"],
                    json={"content": "Great read, @editor and @mod should see this. @nobody"}).json()
    assert c["status"] == "visible" and {m["username"] for m in c["mentions"]} == {"editor", "mod"}
    assert any(m["id"] == c["id"] for m in client.get("/api/users/me/mentions", headers=auth["mod"]).json())
    spam = client.post(f"/api/documents/{doc['id']}/comments", headers=auth["reader"],
                       json={"content": "FREE MONEY click here now"}).json()
    assert spam["status"] == "pending"
    public = client.get(f"/api/documents/{doc['id']}/comments").json()
    assert [x["id"] for x in public] == [c["id"]]  # pending is hidden from others
    assert client.post(f"/api/documents/{doc['id']}/like", headers=auth["reader"]).json() == {"liked": True, "like_count": 1}
    assert client.post(f"/api/documents/{doc['id']}/like", headers=auth["reader"]).json()["liked"] is False
    assert client.put(f"/api/documents/{doc['id']}/rating", headers=auth["reader"], json={"score": 4}).json()["my_rating"] == 4
    assert client.put(f"/api/documents/{doc['id']}/rating", headers=auth["mod"], json={"score": 2}).json()["rating_avg"] == 3.0
    assert client.put(f"/api/documents/{doc['id']}/rating", headers=auth["mod"], json={"score": 9}).status_code == 422
    edited = client.put(f"/api/comments/{c['id']}", headers=auth["reader"], json={"content": "Edited, thanks @seo"}).json()
    assert [m["username"] for m in edited["mentions"]] == ["seo"]
    rep = client.post("/api/reports", headers=auth["editor"], json={"target_type": "comment", "target_id": c["id"],
                                                                   "reason": "Off-topic"})
    assert rep.status_code == 201
    # moderator workflow
    queue = client.get("/api/admin/moderation/comments", headers=auth["mod"]).json()
    assert any(x["id"] == spam["id"] and x["spam_match"] for x in queue["items"])
    assert client.put(f"/api/admin/moderation/comments/{spam['id']}/status", headers=auth["mod"],
                      json={"status": "spam"}).json()["status"] == "spam"
    reports = client.get("/api/admin/moderation/reports", headers=auth["mod"]).json()["items"]
    rid = next(r["id"] for r in reports if r["target_id"] == c["id"])
    done = client.put(f"/api/admin/moderation/reports/{rid}", headers=auth["mod"],
                      json={"status": "resolved", "note": "Hidden", "hide_target": True}).json()
    assert done["status"] == "resolved"
    assert client.get(f"/api/documents/{doc['id']}/comments").json() == []
    me = client.get("/api/auth/me", headers=auth["reader"]).json()
    assert client.put(f"/api/admin/moderation/users/{me['id']}/mute", params={"muted": True},
                      headers=auth["mod"]).json()["is_muted"] is True
    assert client.post(f"/api/documents/{doc['id']}/comments", headers=auth["reader"],
                       json={"content": "hello"}).status_code == 403
    client.put(f"/api/admin/moderation/users/{me['id']}/mute", params={"muted": False}, headers=auth["mod"])
    kw = client.put("/api/admin/moderation/spam-keywords", headers=auth["mod"],
                    json={"keywords": ["Lottery Win", " cheap pills "]}).json()
    assert kw["keywords"] == ["cheap pills", "lottery win"]


# ------------------------------------------------------------- search + click logs
def test_search_filters_and_logging(client, auth, category_ids):
    make_doc(client, auth["editor"], category_ids["technology"], title="Quantum computing basics",
             content="<p>Qubits use superposition. Quantum computers solve some problems faster.</p>",
             tags=("quantum",))
    make_doc(client, auth["editor"], category_ids["health"], title="Gut bacteria and mood",
             content="<p>The microbiome talks to the brain. Quantum effects are not involved.</p>", tags=("biology",))
    r = client.get("/api/search", params={"q": "quantum"}, headers={**auth["reader"], "X-Session-Id": "s1"}).json()
    assert r["total"] == 2 and r["items"][0]["title"] == "Quantum computing basics"  # title match first
    assert r["items"][0]["rank"] == 1 and "quantum" in r["items"][1]["snippet"].lower()
    assert client.get("/api/search", params={"q": "quantum", "category": "health"}).json()["total"] == 1
    assert client.get("/api/search", params={"q": "quantum", "tag": "quantum"}).json()["total"] == 1
    assert client.get("/api/search", params={"q": "qubits superposition"}).json()["total"] == 1
    assert client.get("/api/search", params={"q": "100%_"}).json()["total"] == 0  # LIKE wildcards escaped
    assert client.get("/api/search", params={"q": "quantum", "date_from": "2000-01-01",
                                             "date_to": "2000-01-02"}).json()["total"] == 0
    assert client.get("/api/search", params={"date_from": "2030-01-02", "date_to": "2030-01-01"}).status_code == 400
    click = client.post("/api/search/click", headers={**auth["reader"], "X-Session-Id": "s1"},
                        json={"search_log_id": r["search_log_id"], "document_id": r["items"][0]["id"],
                              "rank_position": 1})
    assert click.status_code == 201
    with SessionLocal() as db:
        s = db.get(SearchClickLog, r["search_log_id"])
        c = db.get(SearchClickLog, click.json()["id"])
    assert s.event_type == "search" and s.query_string == "quantum" and s.user_id and s.results_count == 2
    assert s.clicked_doc_id is None and s.timestamp
    assert c.event_type == "click" and c.clicked_doc_id == r["items"][0]["id"] and c.query_string == "quantum"
    assert c.search_log_id == s.id and c.rank_position == 1 and c.user_id == s.user_id
    assert client.post("/api/search/click", json={"search_log_id": 99999, "document_id": 1,
                                                  "rank_position": 1}).status_code == 404
    logs = client.get("/api/admin/search-logs", headers=auth["boss"], params={"q": "quantum"}).json()
    assert logs["total"] >= 2
    dash = client.get("/api/admin/analytics", headers=auth["seo"]).json()
    assert dash["totals"]["searches"] >= 1 and dash["totals"]["clicks"] >= 1
    assert any(q["query"] == "quantum" for q in dash["top_queries"])


# --------------------------------------------------------------------- super admin
def test_super_admin_users_roles_settings_logs(client, auth):
    new = client.post("/api/admin/users", headers=auth["boss"], json={
        "username": "writer2", "email": "w2@test.io", "password": "password123", "role": "content_manager"})
    assert new.status_code == 201 and new.json()["role"] == "content_manager"
    uid = new.json()["id"]
    assert client.put(f"/api/admin/users/{uid}", headers=auth["boss"], json={"role": "moderator"}).json()["role"] == "moderator"
    assert client.put(f"/api/admin/users/{uid}", headers=auth["boss"], json={"is_active": False}).json()["is_active"] is False
    assert client.post("/api/auth/login", json={"username": "writer2", "password": "password123"}).status_code == 403
    boss_id = client.get("/api/auth/me", headers=auth["boss"]).json()["id"]
    assert client.put(f"/api/admin/users/{boss_id}", headers=auth["boss"], json={"role": "user"}).status_code == 400
    # assign permissions: give moderators analytics.view, then remove it
    roles = client.get("/api/admin/roles", headers=auth["boss"]).json()
    mod_perms = next(r["permissions"] for r in roles["roles"] if r["name"] == "moderator")
    client.put("/api/admin/roles/moderator/permissions", headers=auth["boss"],
               json={"permissions": mod_perms + ["analytics.view"]})
    assert client.get("/api/admin/analytics", headers=auth["mod"]).status_code == 200
    client.put("/api/admin/roles/moderator/permissions", headers=auth["boss"], json={"permissions": mod_perms})
    assert client.get("/api/admin/analytics", headers=auth["mod"]).status_code == 403
    assert client.put("/api/admin/roles/super_admin/permissions", headers=auth["boss"],
                      json={"permissions": ["log.view"]}).status_code == 400
    assert client.put("/api/admin/roles/moderator/permissions", headers=auth["boss"],
                      json={"permissions": ["fly"]}).status_code == 400
    s = client.put("/api/admin/settings", headers=auth["boss"], json={"site_name": "Lantern Test",
                                                                       "items_per_page": 6}).json()
    assert s["site_name"] == "Lantern Test" and client.get("/api/settings").json()["items_per_page"] == 6
    client.put("/api/admin/settings", headers=auth["boss"], json={"allow_registration": False})
    assert client.post("/api/auth/register", json={"username": "late", "email": "l@test.io",
                                                   "password": "password123"}).status_code == 403
    client.put("/api/admin/settings", headers=auth["boss"], json={"allow_registration": True, "items_per_page": 9})
    logs = client.get("/api/admin/logs", headers=auth["boss"], params={"action": "role."}).json()
    assert logs["total"] >= 2 and logs["items"][0]["actor"]["username"] == "boss"


def test_upload_validates_images(client, auth):
    png = b"\x89PNG\r\n\x1a\n" + b"0" * 100
    r = client.post("/api/admin/uploads", headers=auth["editor"], files={"file": ("a.png", png, "image/png")})
    assert r.status_code == 201 and r.json()["url"].startswith("/uploads/")
    assert client.get(r.json()["url"]).status_code == 200
    bad = client.post("/api/admin/uploads", headers=auth["editor"],
                      files={"file": ("x.svg", b"<svg onload=alert(1)>", "image/svg+xml")})
    assert bad.status_code == 415
    assert client.post("/api/admin/uploads", headers=auth["reader"],
                       files={"file": ("a.png", png, "image/png")}).status_code == 403
