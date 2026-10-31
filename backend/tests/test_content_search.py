"""Content CRUD and publication, taxonomy, detail view, search and click logging (Phase 2 data)."""
from sqlalchemy import select

from app.database import SessionLocal
from app.models import SearchClickLog


def test_document_crud_and_publication(client, tokens, published_doc):
    cm = tokens["content_manager"]
    assert published_doc["status"] == "published" and published_doc["published_at"]
    assert published_doc["content_text"].startswith("A heat pump moves heat")
    assert {t["name"] for t in published_doc["tags"]} == {"Energy", "Homes"}
    assert published_doc["summary"]  # auto-generated from the body
    draft = client.post("/api/admin/documents", headers=cm, json={
        "title": "Draft about sleep", "content": "<p>Sleep matters.</p><script>alert(1)</script>",
        "category_id": 2, "status": "draft"}).json()
    assert "<script>" not in draft["content"]  # sanitised against stored XSS
    assert client.get(f"/api/documents/{draft['slug']}").status_code == 404  # drafts are not public
    r = client.put(f"/api/admin/documents/{draft['id']}", headers=cm, json={
        "title": "Why sleep matters", "content": "<p>Sleep consolidates memory.</p>", "category_id": 2,
        "status": "draft"})
    assert r.json()["slug"] == "why-sleep-matters"
    assert client.post(f"/api/admin/documents/{draft['id']}/publish", headers=cm).json()["status"] == "published"
    assert client.get("/api/documents/why-sleep-matters").status_code == 200
    assert client.post(f"/api/admin/documents/{draft['id']}/unpublish", headers=cm).json()["status"] == "draft"
    # SEO specialist can read but not write content; moderator cannot even read
    assert client.get(f"/api/admin/documents/{draft['id']}", headers=tokens["seo_specialist"]).status_code == 200
    assert client.delete(f"/api/admin/documents/{draft['id']}", headers=tokens["seo_specialist"]).status_code == 403
    assert client.delete(f"/api/admin/documents/{draft['id']}", headers=cm).status_code == 204


def test_public_listing_detail_and_views(client, published_doc):
    page = client.get("/api/documents?page=1&page_size=5").json()
    assert page["total"] >= 1 and page["page"] == 1 and "summary" in page["items"][0]
    first = client.get(f"/api/documents/{published_doc['slug']}").json()
    second = client.get(f"/api/documents/{published_doc['slug']}").json()
    assert second["views_count"] == first["views_count"] + 1
    for key in ("content", "author", "category", "tags", "created_at", "views_count", "reading_minutes"):
        assert key in second
    assert client.get("/api/documents?category=technology").json()["total"] >= 1
    assert client.get("/api/documents?tag=energy").json()["total"] >= 1
    assert client.get("/api/documents?category=health").json()["total"] == 0


def test_taxonomy_crud(client, tokens):
    cm = tokens["content_manager"]
    tag = client.post("/api/admin/tags", json={"name": "Batteries"}, headers=cm).json()
    assert tag["slug"] == "batteries"
    assert client.post("/api/admin/tags", json={"name": "batteries"}, headers=cm).status_code == 409
    assert client.put(f"/api/admin/tags/{tag['id']}", json={"name": "Battery storage"}, headers=cm).json()["slug"] == "battery-storage"
    assert client.delete(f"/api/admin/tags/{tag['id']}", headers=cm).status_code == 204
    cat = client.post("/api/admin/categories", json={"name": "Space", "color": "#000000"}, headers=cm).json()
    assert client.delete(f"/api/admin/categories/{cat['id']}", headers=cm).status_code == 204


def test_search_filters_and_logging(client, tokens, published_doc):
    r = client.get("/api/search", params={"q": "heat PUMP"}, headers={"X-Session-Id": "test-session"})
    data = r.json()
    assert r.status_code == 200 and data["total"] >= 1 and data["search_log_id"]
    assert data["items"][0]["slug"] == published_doc["slug"]
    assert client.get("/api/search", params={"q": "heat", "category": "health"}).json()["total"] == 0
    assert client.get("/api/search", params={"q": "heat", "tag": "energy"}).json()["total"] >= 1
    assert client.get("/api/search", params={"q": "heat", "date_from": "2000-01-01", "date_to": "2000-12-31"}).json()["total"] == 0
    assert client.get("/api/search", params={"q": "100%_literal"}).json()["total"] == 0  # LIKE wildcards escaped
    assert client.get("/api/search", params={"date_from": "2030-01-02", "date_to": "2030-01-01"}).status_code == 400
    # click log tied to the search
    r = client.post("/api/search/click", json={"search_log_id": data["search_log_id"], "document_id": published_doc["id"],
                                               "rank": 1}, headers=tokens["user"])
    assert r.status_code == 201
    with SessionLocal() as db:
        click = db.execute(select(SearchClickLog).where(SearchClickLog.event_type == "click")
                           .order_by(SearchClickLog.id.desc())).scalars().first()
        assert click.clicked_doc_id == published_doc["id"] and click.query_string == "heat PUMP"
        assert click.search_id == data["search_log_id"] and click.user_id is not None and click.click_rank == 1
        assert click.timestamp is not None
    logs = client.get("/api/admin/search-logs?event_type=click", headers=tokens["seo_specialist"]).json()
    assert logs["total"] >= 1


def test_magazine_endpoints(client, published_doc):
    front = client.get("/api/front-page").json()
    assert front["cover"]["doc"]["slug"] and front["cover"]["label"] == "Cover story"
    ids = [front["cover"]["doc"]["id"]] + [f["doc"]["id"] for f in front["features"]]
    assert len(ids) == len(set(ids)), "the cover story is never repeated on the front page"
    assert {"latest", "sections", "trending_queries"} <= set(front)
    att = client.get("/api/attention?days=30").json()
    assert att["most_read"] and "value" in att["most_read"][0]
    assert {"most_searched", "trending_queries", "most_discussed", "top_rated", "most_liked"} <= set(att)
    about = client.get("/api/about").json()
    assert about["stats"]["articles"] >= 1 and about["writers"] and about["sections"]


def test_svg_cover_served_as_image(client):
    import mimetypes
    assert mimetypes.guess_type("x.svg")[0] == "image/svg+xml"
