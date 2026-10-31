"""
One-command launcher (works from any folder, on Windows, macOS and Linux).

    python run.py                # create + seed the database if needed, then start the site
    python run.py --install      # install Python requirements first
    python run.py --reset        # wipe the database and seed it again
    python run.py --test         # run the backend test suite
    python run.py --port 8080 --no-browser

The site opens at http://127.0.0.1:8000  (API docs: /docs).
"""
import argparse
import os
import subprocess
import sys
import threading
import webbrowser
from pathlib import Path

ROOT = Path(__file__).resolve().parent
BACKEND = ROOT / "backend"


def main() -> None:
    p = argparse.ArgumentParser(description="Run the Margin news portal")
    p.add_argument("--install", action="store_true", help="pip install backend requirements first")
    p.add_argument("--reset", action="store_true", help="drop and re-seed the database")
    p.add_argument("--test", action="store_true", help="run the test suite and exit")
    p.add_argument("--host", default="127.0.0.1")
    p.add_argument("--port", type=int, default=8000)
    p.add_argument("--no-browser", action="store_true")
    args = p.parse_args()

    os.chdir(BACKEND)
    sys.path.insert(0, str(BACKEND))
    if args.install:
        subprocess.check_call([sys.executable, "-m", "pip", "install", "-r", "requirements.txt"])
    if args.test:
        sys.exit(subprocess.call([sys.executable, "-m", "pytest", "-q", "tests"]))
    try:
        import uvicorn
        from sqlalchemy import func, select

        from app.config import settings
        from app.database import SessionLocal, init_db
        from app.models import Document
        from seed.seed import seed
    except ImportError as exc:
        sys.exit(f"Missing dependency ({exc.name}). Run:  python run.py --install")

    init_db()
    with SessionLocal() as db:
        empty = not db.scalar(select(func.count()).select_from(Document))
    if args.reset or empty:
        print("Seeding the database with demo content ...")
        seed(reset=args.reset)
    if not (settings.frontend_dist / "index.html").exists():
        print("Note: frontend build not found. Run `npm install && npm run build` in frontend/.")
    url = f"http://{args.host}:{args.port}"
    print(f"\n  Margin is running at {url}   (API docs: {url}/docs)\n"
          f"  Database: {settings.database_url.split('@')[-1]}\n"
          "  Demo logins (password demo1234): admin, editor, moderator, seo, reader\n"
          "  Press Ctrl+C to stop.\n")
    if not args.no_browser:
        threading.Timer(1.5, lambda: webbrowser.open(url)).start()
    uvicorn.run("app.main:app", host=args.host, port=args.port, log_level="warning")


if __name__ == "__main__":
    main()
