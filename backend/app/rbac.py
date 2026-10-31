"""Role and permission catalogue (the single source of truth for RBAC)."""
from __future__ import annotations

PERMISSIONS: dict[str, str] = {
    "users.manage": "Create, edit, deactivate user accounts and change their roles",
    "roles.manage": "Assign permissions to roles",
    "logs.view": "View system (audit) logs and raw search/click logs",
    "settings.manage": "Configure global site settings",
    "documents.manage": "Create, edit and delete articles",
    "documents.publish": "Publish and unpublish articles",
    "taxonomy.manage": "Create, edit and delete categories and tags",
    "comments.moderate": "Review comments, mark spam, manage spam rules",
    "reports.handle": "Review and resolve user reports (flags)",
    "seo.manage": "Edit SEO metadata (titles, descriptions, keywords, alt text)",
    "analytics.view": "View the analytics dashboard",
}

ROLES: dict[str, dict] = {
    "super_admin": {
        "label": "Super Admin",
        "description": "Manages users, roles and permissions, system logs and global settings.",
        "permissions": list(PERMISSIONS),
    },
    "content_manager": {
        "label": "Content Manager",
        "description": "Full CRUD on content, publication status and taxonomy.",
        "permissions": ["documents.manage", "documents.publish", "taxonomy.manage"],
    },
    "moderator": {
        "label": "Moderator",
        "description": "Reviews user comments, handles reports and controls spam.",
        "permissions": ["comments.moderate", "reports.handle"],
    },
    "seo_specialist": {
        "label": "Data & SEO Specialist",
        "description": "Configures SEO metadata and monitors analytics.",
        "permissions": ["seo.manage", "analytics.view"],
    },
    "user": {
        "label": "Member",
        "description": "Registered reader: profile, comments, likes, ratings and mentions.",
        "permissions": [],
    },
}

DEFAULT_ROLE = "user"
# Permissions the super_admin role can never lose (prevents locking everyone out).
PROTECTED_SUPER_ADMIN_PERMISSIONS = {"users.manage", "roles.manage"}

DEFAULT_SETTINGS: dict[str, str] = {
    "site_name": "Margin",
    "site_tagline": "Clear explainers on technology, science, health and the world around us.",
    "page_size": "9",
    "allow_registration": "true",
    "comments_require_approval": "false",
    "max_links_per_comment": "2",
    "comment_rate_limit_per_minute": "5",
    "spam_keywords": "free money, casino, crypto giveaway, click here, buy followers, viagra, loan approval",
}
PUBLIC_SETTINGS = ("site_name", "site_tagline", "page_size", "allow_registration")
