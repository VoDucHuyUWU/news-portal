"""Authentication, profile management and role-based access control."""
import pytest

STAFF_ENDPOINTS = {
    # endpoint: roles that must be allowed (everyone else must get 403)
    ("GET", "/api/admin/users"): {"super_admin"},
    ("GET", "/api/admin/permissions"): {"super_admin"},
    ("GET", "/api/admin/audit-logs"): {"super_admin"},
    ("GET", "/api/admin/settings"): {"super_admin"},
    ("GET", "/api/admin/documents"): {"super_admin", "content_manager", "seo_specialist"},
    ("POST", "/api/admin/categories"): {"super_admin", "content_manager"},
    ("GET", "/api/admin/comments"): {"super_admin", "moderator"},
    ("GET", "/api/admin/reports"): {"super_admin", "moderator"},
    ("GET", "/api/admin/spam-rules"): {"super_admin", "moderator"},
    ("GET", "/api/admin/seo"): {"super_admin", "seo_specialist"},
    ("GET", "/api/admin/analytics"): {"super_admin", "seo_specialist"},
}


def test_register_login_me_and_profile(client):
    r = client.post("/api/auth/register", json={"username": "newbie", "email": "NewBie@Example.com",
                                                "password": "secret123", "full_name": "New Bie"})
    assert r.status_code == 201, r.text
    data = r.json()
    assert data["user"]["role"]["name"] == "user" and data["user"]["permissions"] == []
    assert data["user"]["email"] == "newbie@example.com"
    dup = client.post("/api/auth/register", json={"username": "NEWBIE", "email": "x@example.com", "password": "secret123"})
    assert dup.status_code == 409
    bad = client.post("/api/auth/login", json={"login": "newbie", "password": "wrong-pass"})
    assert bad.status_code == 401
    login = client.post("/api/auth/login", json={"login": "newbie@example.com", "password": "secret123"})
    headers = {"Authorization": f"Bearer {login.json()['access_token']}"}
    assert client.get("/api/auth/me", headers=headers).json()["username"] == "newbie"
    r = client.patch("/api/users/me", json={"bio": "I read about science.", "full_name": "Newbie Reader"}, headers=headers)
    assert r.json()["bio"] == "I read about science."
    assert client.post("/api/users/me/password", json={"current_password": "nope", "new_password": "another123"},
                       headers=headers).status_code == 400
    assert client.post("/api/users/me/password", json={"current_password": "secret123", "new_password": "another123"},
                       headers=headers).status_code == 204
    assert client.post("/api/auth/login", json={"login": "newbie", "password": "another123"}).status_code == 200


def test_validation_and_auth_errors(client):
    assert client.post("/api/auth/register", json={"username": "ab", "email": "bad", "password": "1"}).status_code == 422
    assert client.get("/api/auth/me").status_code == 401
    assert client.get("/api/auth/me", headers={"Authorization": "Bearer not-a-token"}).status_code == 401


@pytest.mark.parametrize("endpoint,allowed", list(STAFF_ENDPOINTS.items()), ids=[e[1] for e in STAFF_ENDPOINTS])
def test_rbac_matrix(client, tokens, endpoint, allowed):
    method, path = endpoint
    for role, headers in tokens.items():
        body = {"name": f"Category for {role}", "color": "#123456"} if method == "POST" else None
        r = client.request(method, path, headers=headers, json=body)
        if role in allowed:
            assert r.status_code in (200, 201), f"{role} should access {path}: {r.status_code} {r.text}"
        else:
            assert r.status_code == 403, f"{role} must NOT access {path}: got {r.status_code}"
    assert client.request(method, path, json={"name": "anon"}).status_code == 401  # anonymous


def test_role_permission_assignment_and_protection(client, tokens):
    roles = {r["name"]: r for r in client.get("/api/admin/roles", headers=tokens["super_admin"]).json()}
    mod = roles["moderator"]
    # grant analytics to moderators, then the moderator can open analytics
    r = client.put(f"/api/admin/roles/{mod['id']}/permissions", headers=tokens["super_admin"],
                   json={"permissions": mod["permissions"] + ["analytics.view"]})
    assert r.status_code == 200 and "analytics.view" in r.json()["permissions"]
    assert client.get("/api/admin/analytics", headers=tokens["moderator"]).status_code == 200
    client.put(f"/api/admin/roles/{mod['id']}/permissions", headers=tokens["super_admin"],
               json={"permissions": mod["permissions"]})
    assert client.get("/api/admin/analytics", headers=tokens["moderator"]).status_code == 403
    # super admin cannot remove its own lock-out-critical permissions
    r = client.put(f"/api/admin/roles/{roles['super_admin']['id']}/permissions", headers=tokens["super_admin"],
                   json={"permissions": ["logs.view"]})
    assert r.status_code == 400


def test_user_management_and_last_super_admin(client, tokens):
    users = client.get("/api/admin/users?q=boss", headers=tokens["super_admin"]).json()["items"]
    boss = users[0]
    roles = {r["name"]: r["id"] for r in client.get("/api/admin/roles", headers=tokens["super_admin"]).json()}
    r = client.patch(f"/api/admin/users/{boss['id']}", json={"role_id": roles["user"]}, headers=tokens["super_admin"])
    assert r.status_code == 400  # the only super admin cannot be demoted
    created = client.post("/api/admin/users", headers=tokens["super_admin"], json={
        "username": "writer2", "email": "writer2@test.io", "password": "password123", "role_id": roles["content_manager"]})
    assert created.status_code == 201 and created.json()["role"]["name"] == "content_manager"
    r = client.patch(f"/api/admin/users/{created.json()['id']}", json={"is_active": False}, headers=tokens["super_admin"])
    assert r.json()["is_active"] is False
    assert client.post("/api/auth/login", json={"login": "writer2", "password": "password123"}).status_code == 403
    logs = client.get("/api/admin/audit-logs?action=user.", headers=tokens["super_admin"]).json()["items"]
    assert any("deactivated" in log["detail"] for log in logs)


def test_global_settings(client, tokens):
    r = client.put("/api/admin/settings", json={"site_name": "Margin Test"}, headers=tokens["super_admin"])
    assert r.status_code == 200 and r.json()["site_name"] == "Margin Test"
    assert client.get("/api/settings/public").json()["site_name"] == "Margin Test"
    assert client.put("/api/admin/settings", json={"nope": "1"}, headers=tokens["super_admin"]).status_code == 400
    client.put("/api/admin/settings", json={"allow_registration": "false"}, headers=tokens["super_admin"])
    r = client.post("/api/auth/register", json={"username": "late", "email": "late@x.io", "password": "secret123"})
    assert r.status_code == 403
    client.put("/api/admin/settings", json={"allow_registration": "true", "site_name": "Margin"}, headers=tokens["super_admin"])
