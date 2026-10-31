"""Comments with @mentions, likes, ratings, reports, moderation queue, spam control, SEO and analytics."""


def test_likes_and_ratings(client, tokens, published_doc):
    reader, doc_id = tokens["user"], published_doc["id"]
    assert client.post(f"/api/documents/{doc_id}/like").status_code == 401
    r = client.post(f"/api/documents/{doc_id}/like", headers=reader).json()
    assert r["liked_by_me"] and r["like_count"] == 1
    assert client.post(f"/api/documents/{doc_id}/like", headers=reader).json()["like_count"] == 0  # toggle
    client.put(f"/api/documents/{doc_id}/rating", json={"score": 4}, headers=reader)
    r = client.put(f"/api/documents/{doc_id}/rating", json={"score": 2}, headers=tokens["moderator"]).json()
    assert r["rating_count"] == 2 and r["rating_avg"] == 3.0
    assert client.put(f"/api/documents/{doc_id}/rating", json={"score": 9}, headers=reader).status_code == 422


def test_comments_mentions_and_spam(client, tokens, published_doc):
    reader, doc_id = tokens["user"], published_doc["id"]
    c = client.post(f"/api/documents/{doc_id}/comments", json={"content": "Great explainer, @mod what do you think?"},
                    headers=reader).json()
    assert c["status"] == "visible" and c["mentions"] == ["mod"]
    reply = client.post(f"/api/documents/{doc_id}/comments", json={"content": "Agreed!", "parent_id": c["id"]},
                        headers=tokens["moderator"]).json()
    assert reply["parent_id"] == c["id"]
    mentions = client.get("/api/users/me/mentions", headers=tokens["moderator"]).json()
    assert mentions and mentions[0]["by"]["username"] == "reader"
    assert client.get("/api/users/lookup?q=mo").json()[0]["username"] == "mod"
    spam = client.post(f"/api/documents/{doc_id}/comments", json={"content": "FREE MONEY at my casino, click here"},
                       headers=reader).json()
    assert spam["status"] == "pending"  # auto-flagged, waits for a moderator
    public = client.get(f"/api/documents/{doc_id}/comments").json()
    assert spam["id"] not in [x["id"] for x in public]
    queue = client.get("/api/admin/comments?status=pending", headers=tokens["moderator"]).json()["items"]
    assert any(x["id"] == spam["id"] and "spam keyword" in x["flag_reason"] for x in queue)
    assert client.patch(f"/api/admin/comments/{spam['id']}", json={"status": "spam"},
                        headers=tokens["moderator"]).json()["status"] == "spam"
    assert client.post("/api/admin/comments/purge-spam", headers=tokens["moderator"]).json()["deleted"] >= 1


def test_comment_rate_limit(client, tokens, published_doc):
    client.put("/api/admin/spam-rules", headers=tokens["moderator"], json={
        "spam_keywords": "casino", "max_links_per_comment": 2, "comment_rate_limit_per_minute": 3,
        "comments_require_approval": False})
    codes = [client.post(f"/api/documents/{published_doc['id']}/comments", json={"content": f"Comment {i}"},
                         headers=tokens["user"]).status_code for i in range(5)]
    assert 429 in codes
    client.put("/api/admin/spam-rules", headers=tokens["moderator"], json={
        "spam_keywords": "casino, free money, click here", "max_links_per_comment": 2,
        "comment_rate_limit_per_minute": 50, "comments_require_approval": False})


def test_reports_flow(client, tokens, published_doc):
    c = client.post(f"/api/documents/{published_doc['id']}/comments", json={"content": "You are all idiots"},
                    headers=tokens["user"]).json()
    r = client.post("/api/reports", json={"target_type": "comment", "target_id": c["id"], "reason": "Insulting"},
                    headers=tokens["content_manager"])
    assert r.status_code == 201
    open_reports = client.get("/api/admin/reports", headers=tokens["moderator"]).json()["items"]
    rep = next(x for x in open_reports if x["target_id"] == c["id"])
    assert "idiots" in rep["target_preview"]
    r = client.patch(f"/api/admin/reports/{rep['id']}", json={"status": "resolved", "action": "hide"},
                     headers=tokens["moderator"])
    assert r.json()["status"] == "resolved"
    assert c["id"] not in [x["id"] for x in client.get(f"/api/documents/{published_doc['id']}/comments").json()]


def test_seo_and_analytics(client, tokens, published_doc):
    seo = tokens["seo_specialist"]
    r = client.put(f"/api/admin/seo/{published_doc['id']}", headers=seo, json={
        "meta_title": "How heat pumps work | Margin",
        "meta_description": "A plain-language guide to how heat pumps move heat and why they are efficient.",
        "keywords": "heat pump, energy, home heating", "image_alt": "Diagram of a heat pump cycle"})
    assert r.status_code == 200 and r.json()["completeness"] == 100 and r.json()["missing"] == []
    detail = client.get(f"/api/documents/{published_doc['slug']}").json()
    assert detail["seo"]["image_alt"] == "Diagram of a heat pump cycle"
    assert client.put(f"/api/admin/seo/{published_doc['id']}", headers=tokens["content_manager"],
                      json={"meta_title": "x"}).status_code == 403
    a = client.get("/api/admin/analytics?days=7", headers=seo).json()
    assert len(a["daily_views"]) == 7 and a["totals"]["views_in_period"] >= 1
    assert a["totals"]["searches"] >= 1 and a["top_queries"]
