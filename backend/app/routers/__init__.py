"""API routers, registered in order."""
from app.routers import auth, users

ROUTERS = [auth.router, users.router]
