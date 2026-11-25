"""
Offline comparison of the three rankers: Phase 1 (SQL LIKE), TF-IDF and BM25.

    cd backend
    python -m app.search_eval                       # uses the configured database
    python -m app.search_eval --sqlite news_portal.db

Two experiments, both reproducible (fixed random seed):

1. Known-item search. For every published article, a query of 1, 2 or 3 words is drawn from its own summary.
   A good ranker puts that article first. Reported: Success@1 (target is the top result) and MRR@10.
2. Word-form robustness. The distinct queries of the search log are re-typed in another word form
   (singular <-> plural). Reported: how many queries return nothing.

The queries are generated, not typed by real users: the numbers compare rankers on this corpus, nothing more.
"""
from __future__ import annotations

import argparse
import random
import re
from typing import Any

from app.search_engine import STOPWORDS, InvertedIndex

RANKERS = ("like", "tfidf", "bm25")
WORD_RE = re.compile(r"[a-z]+")


# ---------------------------------------------------------------- Phase 1 baseline, re-stated in plain Python
def like_terms(query: str) -> list[str]:
    seen: list[str] = []
    for raw in query.lower().split():
        term = raw.strip(".,;:!?\"'()[]{}")
        if term and term not in seen:
            seen.append(term)
    return seen[:8]


def like_search(documents: list[dict[str, Any]], query: str) -> list[int]:
    """Every term must be a substring of title, summary, body or a tag; more title hits first, then newest."""
    terms = like_terms(query)
    if not terms:
        return []
    hits = []
    for doc in documents:
        title = (doc.get("title") or "").lower()
        fields = [title, (doc.get("summary") or "").lower(), (doc.get("content_text") or "").lower()]
        fields += [t.lower() for t in doc.get("tags") or []]
        if all(any(term in f for f in fields) for term in terms):
            hits.append((-sum(term in title for term in terms), doc.get("published_at") or "", doc["id"]))
    # title hits descending, then newest first
    hits.sort(key=lambda h: (h[0], _neg_date(h[1])))
    return [h[2] for h in hits]


def _neg_date(value: Any) -> str:
    """Sort key that puts newer ISO timestamps first (works for str and datetime)."""
    text = str(value)
    return "".join(chr(255 - ord(ch)) if ord(ch) < 255 else ch for ch in text)


def run(documents: list[dict[str, Any]], index: InvertedIndex, ranker: str, query: str) -> list[int]:
    if ranker == "like":
        return like_search(documents, query)
    return [doc_id for doc_id, _ in index.search(query, ranker)]


# ---------------------------------------------------------------- experiment 1: known-item search
def known_item_queries(documents: list[dict[str, Any]], words: int, seed: int = 13) -> list[tuple[str, int]]:
    out = []
    for doc in documents:
        pool = sorted({w for w in WORD_RE.findall((doc.get("summary") or "").lower()) if len(w) >= 4 and w not in STOPWORDS})
        if len(pool) < words:
            continue
        rng = random.Random(seed * 1000 + int(doc["id"]) * 10 + words)
        out.append((" ".join(rng.sample(pool, words)), doc["id"]))
    return out


def known_item(documents: list[dict[str, Any]], index: InvertedIndex, words: int) -> dict[str, dict[str, float]]:
    queries = known_item_queries(documents, words)
    out: dict[str, dict[str, float]] = {}
    for ranker in RANKERS:
        top1 = rr = 0.0
        for query, target in queries:
            ranked = run(documents, index, ranker, query)[:10]
            if target in ranked:
                position = ranked.index(target) + 1
                rr += 1.0 / position
                top1 += position == 1
        n = len(queries) or 1
        out[ranker] = {"queries": len(queries), "success_at_1": round(top1 / n, 3), "mrr_at_10": round(rr / n, 3)}
    return out


# ---------------------------------------------------------------- experiment 2: word forms
def other_form(query: str) -> str:
    """Re-type the last word in its other number: 'heat pump' -> 'heat pumps', 'passkeys' -> 'passkey'."""
    words = query.split()
    last = words[-1]
    if len(last) <= 3:
        return query                           # too short to inflect safely (gps, d)
    if last.endswith("ies") and len(last) > 4:
        last = last[:-3] + "y"
    elif last.endswith("ss"):
        last = last + "es"                     # stress -> stresses
    elif last.endswith("s"):
        last = last[:-1]
    elif last.endswith("y") and len(last) > 3 and last[-2] not in "aeiou":
        last = last[:-1] + "ies"
    else:
        last = last + "s"
    return " ".join(words[:-1] + [last])


def word_forms(documents: list[dict[str, Any]], index: InvertedIndex, queries: list[str]) -> dict[str, dict[str, int]]:
    out: dict[str, dict[str, int]] = {}
    for ranker in RANKERS:
        as_typed = sum(not run(documents, index, ranker, q) for q in queries)
        varied = sum(not run(documents, index, ranker, other_form(q)) for q in queries)
        out[ranker] = {"queries": len(queries), "no_results_as_typed": as_typed, "no_results_other_form": varied}
    return out


def evaluate(documents: list[dict[str, Any]], log_queries: list[str]) -> dict[str, Any]:
    index = InvertedIndex.build(documents)
    return {"documents": len(documents), "vocabulary": index.vocabulary,
            "known_item": {words: known_item(documents, index, words) for words in (1, 2, 3)},
            "word_forms": word_forms(documents, index, log_queries)}


# ---------------------------------------------------------------- loading
def load_sqlite(path: str) -> tuple[list[dict[str, Any]], list[str]]:
    import sqlite3

    con = sqlite3.connect(path)
    con.row_factory = sqlite3.Row
    documents = []
    for row in con.execute("SELECT id, title, summary, content_text, published_at FROM documents WHERE status = 'published'"):
        doc = dict(row)
        doc["tags"] = [t[0] for t in con.execute(
            "SELECT name FROM tags JOIN document_tags ON tag_id = tags.id WHERE document_id = ?", (row["id"],))]
        documents.append(doc)
    queries = [r[0] for r in con.execute(
        "SELECT DISTINCT query_string FROM search_click_logs WHERE event_type = 'search' AND query_string <> '' ORDER BY 1")]
    con.close()
    return documents, queries


def load_app_database() -> tuple[list[dict[str, Any]], list[str]]:
    from sqlalchemy import select

    from app.database import SessionLocal
    from app.models import Document, SearchClickLog

    with SessionLocal() as db:
        documents = [{"id": d.id, "title": d.title, "summary": d.summary, "content_text": d.content_text,
                      "published_at": d.published_at, "tags": [t.name for t in d.tags]}
                     for d in db.execute(select(Document).where(Document.status == "published")).unique().scalars()]
        queries = sorted(q for q in db.scalars(select(SearchClickLog.query_string).where(
            SearchClickLog.event_type == "search").distinct()) if q)
    return documents, queries


def main() -> None:
    parser = argparse.ArgumentParser(description="Compare LIKE, TF-IDF and BM25 on the article collection")
    parser.add_argument("--sqlite", help="path to a SQLite database file (default: the configured database)")
    args = parser.parse_args()
    documents, queries = load_sqlite(args.sqlite) if args.sqlite else load_app_database()
    report = evaluate(documents, queries)
    print(f"{report['documents']} published articles, {report['vocabulary']} distinct terms in the index\n")
    print("Known-item search (query words drawn from the article's own summary)")
    print(f"{'words':>5}  {'ranker':<6}  {'queries':>7}  {'Success@1':>9}  {'MRR@10':>7}")
    for words, by_ranker in report["known_item"].items():
        for ranker, m in by_ranker.items():
            print(f"{words:>5}  {ranker:<6}  {m['queries']:>7}  {m['success_at_1']:>9.3f}  {m['mrr_at_10']:>7.3f}")
    print("\nSearch-log queries that return nothing")
    print(f"{'ranker':<6}  {'queries':>7}  {'as typed':>8}  {'other word form':>15}")
    for ranker, m in report["word_forms"].items():
        print(f"{ranker:<6}  {m['queries']:>7}  {m['no_results_as_typed']:>8}  {m['no_results_other_form']:>15}")


if __name__ == "__main__":
    main()
