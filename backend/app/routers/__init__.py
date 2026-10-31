"""API routers, registered in order."""
from app.routers import admin, analytics, auth, documents, engagement, moderation, search, taxonomy, users

ROUTERS = [auth.router, users.router, documents.router, taxonomy.router, engagement.router, search.router,
           moderation.router, analytics.router, admin.router]
