"""The seed script produces the Phase-2 dataset: >= 50 real articles with all required fields, plus logs."""
import os
import sqlite3
import subprocess
import sys
from pathlib import Path

BACKEND = Path(__file__).resolve().parents[1]


def test_seed_creates_required_dataset(tmp_path):
    db_file = tmp_path / "seed.db"
    env = {**os.environ, "DATABASE_URL": f"sqlite:///{db_file.as_posix()}", "MEDIA_DIR": str(tmp_path / "media")}
    out = subprocess.run([sys.executable, "-m", "seed.seed", "--reset"], cwd=BACKEND, env=env,
                         capture_output=True, text=True, timeout=180)
    assert out.returncode == 0, out.stderr
    con = sqlite3.connect(db_file)
    rows = con.execute("SELECT id, title, content, content_text, summary, category_id, author_id, created_at, "
                       "views_count FROM documents").fetchall()
    assert 50 <= len(rows) <= 100
    for _id, title, content, text, summary, cat, author, created, views in rows:
        assert title and content.startswith("<") and summary and cat and author and created and views is not None
        assert len(text.split()) >= 150 and "lorem" not in text.lower()
    assert con.execute("SELECT COUNT(*) FROM document_tags").fetchone()[0] >= len(rows)
    searches = con.execute("SELECT COUNT(*) FROM search_click_logs WHERE event_type='search'").fetchone()[0]
    clicks = con.execute("SELECT COUNT(*) FROM search_click_logs WHERE event_type='click' AND clicked_doc_id IS NOT NULL "
                         "AND search_id IS NOT NULL AND timestamp IS NOT NULL").fetchone()[0]
    assert searches > 0 and clicks > 0
    roles = {r[0] for r in con.execute("SELECT r.name FROM users u JOIN roles r ON r.id=u.role_id")}
    assert {"super_admin", "content_manager", "moderator", "seo_specialist", "user"} <= roles
    assert len(list((tmp_path / "media" / "covers").glob("*.svg"))) == len(rows)
