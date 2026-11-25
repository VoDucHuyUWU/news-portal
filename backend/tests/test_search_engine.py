"""Phase 2: tokenizer, inverted index, BM25 / TF-IDF ranking, and the search API that uses them."""
import math

from app.search_engine import BM25_B, BM25_K1, InvertedIndex, query_terms, stem, tokenize

DOCS = [
    {"id": 1, "title": "Why sleep matters for students", "summary": "Sleep and memory.",
     "content_text": "Students who sleep well remember more. Sleeping late hurts grades.", "tags": ["Sleep", "Study"]},
    {"id": 2, "title": "How heat pumps heat a home", "summary": "A heat pump moves warmth.",
     "content_text": "A pump moves heat instead of making it. It works like a fridge in reverse.", "tags": ["Energy"]},
    {"id": 3, "title": "Stress and the body", "summary": "What stress does.",
     "content_text": "Stress changes sleep, appetite and attention. A short walk helps students too. " * 6, "tags": ["Health"]},
]


# ---------------------------------------------------------------- tokenizer
def test_tokenize_lowercases_drops_stopwords_and_stems():
    assert tokenize("The Students are SLEEPING, and the pumps!") == ["student", "sleep", "pump"]
    assert tokenize(None) == [] and tokenize("") == [] and tokenize("the and of") == []
    assert tokenize("100%_literal") == ["100", "literal"]


def test_stemmer_joins_word_forms_and_leaves_exceptions():
    assert stem("students") == stem("student") == "student"
    assert stem("studies") == "study" and stem("classes") == "class" and stem("boxes") == "box"
    assert stem("sleeping") == "sleep" and stem("running") == "run" and stem("making") == "make"
    assert stem("saved") == "save" and stem("stopped") == "stop" and stem("need") == "need"
    assert stem("news") == "news" and stem("glass") == "glass" and stem("bus") == "bus" and stem("2024") == "2024"


def test_query_terms_are_distinct_and_capped():
    assert query_terms("sleep SLEEPING sleeps students") == ["sleep", "student"]
    assert len(query_terms(" ".join(f"word{i}" for i in range(20)))) == 8


# ---------------------------------------------------------------- inverted index
def test_inverted_index_postings_and_statistics():
    index = InvertedIndex.build(DOCS)
    assert index.size == 3
    assert set(index.postings["sleep"]) == {1, 3} and index.df("sleep") == 2
    assert set(index.postings["pump"]) == {2} and index.df("nothing") == 0
    # field weights: title x3, tags x2, summary x1.5, body x1  ->  3 + 2 + 1.5 + 2 (sleep, sleeping) = 8.5
    assert index.postings["sleep"][1] == 8.5
    assert index.avg_len == sum(index.doc_len.values()) / 3
    assert index.idf_bm25("pump") > index.idf_bm25("sleep") > 0          # rarer term, higher idf
    assert index.idf_bm25("nothing") == 0


def test_bm25_matches_the_formula_and_ranks_sensibly():
    index = InvertedIndex.build(DOCS)
    tf, dl = index.postings["pump"][2], index.doc_len[2]
    idf = math.log(1 + (3 - 1 + 0.5) / (1 + 0.5))
    expected = idf * tf * (BM25_K1 + 1) / (tf + BM25_K1 * (1 - BM25_B + BM25_B * dl / index.avg_len))
    assert math.isclose(index.score_bm25(["pump"])[2], expected, rel_tol=1e-12)
    for ranker in ("bm25", "tfidf"):
        assert [d for d, _ in index.search("sleeping students", ranker)][0] == 1       # word forms still match
        assert [d for d, _ in index.search("heat pumps", ranker)] == [2]
        assert index.search("quantum", ranker) == [] and index.search("the of", ranker) == []
        scores = [s for _, s in index.search("sleep stress students", ranker)]
        assert scores == sorted(scores, reverse=True) and all(s > 0 for s in scores)
    # OR semantics: a document with only one of the query terms is still returned, below the full match
    assert [d for d, _ in index.search("sleep pump")] != [] and {d for d, _ in index.search("sleep pump")} == {1, 2, 3}
    assert sum(part["score"] for part in index.explain("sleep students", 1)) > 0


# ---------------------------------------------------------------- API
def test_search_api_uses_bm25_by_default_and_can_switch_ranker(client, tokens, published_doc):
    data = client.get("/api/search", params={"q": "heat pumps", "log": "false"}).json()
    assert data["ranker"] == "bm25" and data["total"] >= 1
    assert data["items"][0]["slug"] == published_doc["slug"]
    assert data["scores"][str(published_doc["id"])] > 0
    # "pumps" is not a substring of the article, so the Phase 1 ranker finds nothing; the stemmed index does
    like = client.get("/api/search", params={"q": "heating pumps", "ranker": "like", "log": "false"}).json()
    assert like["ranker"] == "like" and like["total"] == 0 and like["scores"] == {}
    tfidf = client.get("/api/search", params={"q": "heating pumps", "ranker": "tfidf", "log": "false"}).json()
    assert tfidf["ranker"] == "tfidf" and tfidf["items"][0]["slug"] == published_doc["slug"]
    assert client.get("/api/search", params={"q": "heat", "ranker": "nope"}).status_code == 422
    # filters and non-relevance sorts still apply on top of the ranked set
    assert client.get("/api/search", params={"q": "heat pump", "category": "health", "log": "false"}).json()["total"] == 0
    newest = client.get("/api/search", params={"q": "heat pump", "sort": "newest", "log": "false"}).json()
    assert newest["total"] == data["total"]
    assert client.get("/api/search", params={"q": "zzzunknownword", "log": "false"}).json()["total"] == 0


def test_index_follows_content_changes_and_the_log_records_the_ranker(client, tokens):
    body = {"title": "Tardigrades survive almost anything", "summary": "", "status": "published", "category_id": 1,
            "content": "<p>Tardigrades are tiny animals that survive drying out.</p>"}
    assert client.get("/api/search", params={"q": "tardigrade", "log": "false"}).json()["total"] == 0
    created = client.post("/api/admin/documents", json=body, headers=tokens["content_manager"])
    assert created.status_code == 201, created.text
    found = client.get("/api/search", params={"q": "tardigrade"}, headers={"X-Session-Id": "phase2"}).json()
    assert found["total"] == 1 and found["items"][0]["id"] == created.json()["id"] and found["search_log_id"]
    logs = client.get("/api/admin/search-logs", headers=tokens["super_admin"]).json()["items"]
    entry = next(item for item in logs if item["id"] == found["search_log_id"])
    assert entry["filters"]["ranker"] == "bm25" and entry["results_count"] == 1
    assert client.delete(f"/api/admin/documents/{created.json()['id']}", headers=tokens["content_manager"]).status_code == 204
    assert client.get("/api/search", params={"q": "tardigrade", "log": "false"}).json()["total"] == 0
