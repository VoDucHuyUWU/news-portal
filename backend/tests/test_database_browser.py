"""Read-only database browser: schema (primary / foreign keys) and raw rows, Super Admin only."""


def test_tables_expose_primary_and_foreign_keys(client, tokens):
    r = client.get("/api/admin/database/tables", headers=tokens["super_admin"])
    assert r.status_code == 200, r.text
    tables = {t["name"]: t for t in r.json()}
    assert {"users", "roles", "documents", "document_tags", "search_click_logs", "settings"} <= set(tables)

    docs = {c["name"]: c for c in tables["documents"]["columns"]}
    assert tables["documents"]["primary_key"] == ["id"] and docs["id"]["primary_key"] is True
    assert docs["category_id"]["foreign_key"] == "categories.id"
    assert docs["author_id"]["foreign_key"] == "users.id"
    assert docs["title"]["primary_key"] is False and docs["title"]["foreign_key"] is None

    # association table: composite primary key, both parts are foreign keys
    assert set(tables["document_tags"]["primary_key"]) == {"document_id", "tag_id"}
    assert {fk["references"] for fk in tables["document_tags"]["foreign_keys"]} == {"documents.id", "tags.id"}
    # self-reference used to link a click to its search
    logs = {c["name"]: c for c in tables["search_click_logs"]["columns"]}
    assert logs["search_id"]["foreign_key"] == "search_click_logs.id"
    assert tables["settings"]["primary_key"] == ["key"]
    assert tables["users"]["rows"] >= 5


def test_table_rows_are_raw_and_never_leak_password_hashes(client, tokens):
    r = client.get("/api/admin/database/tables/users?page_size=5", headers=tokens["super_admin"])
    assert r.status_code == 200, r.text
    data = r.json()
    assert data["primary_key"] == ["id"] and len(data["items"]) == 5 and data["total"] >= 5
    row = data["items"][0]
    assert set(row) == {c["name"] for c in data["columns"]}
    assert "role_id" in row and isinstance(row["role_id"], int)          # the raw foreign key, not a nested object
    assert all(item["password_hash"] == "(hidden)" for item in data["items"])
    ids = [item["id"] for item in data["items"]]
    assert ids == sorted(ids)
    newest = client.get("/api/admin/database/tables/users?page_size=5&newest_first=true", headers=tokens["super_admin"]).json()
    newest_ids = [item["id"] for item in newest["items"]]
    assert newest_ids == sorted(newest_ids, reverse=True)


def test_database_browser_is_super_admin_only_and_validates_names(client, tokens):
    assert client.get("/api/admin/database/tables/nope", headers=tokens["super_admin"]).status_code == 404
    assert client.get("/api/admin/database/tables").status_code == 401
    for role in ("content_manager", "moderator", "seo_specialist", "user"):
        assert client.get("/api/admin/database/tables", headers=tokens[role]).status_code == 403
        assert client.get("/api/admin/database/tables/users", headers=tokens[role]).status_code == 403
