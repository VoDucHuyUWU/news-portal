"""
Phase 2 search engine: tokenizer, inverted index and two rankers (BM25 and TF-IDF).

Pure Python on purpose (no database or web imports), so it can be unit-tested and evaluated on its own:

    documents ──tokenize──▶ terms ──build──▶ inverted index ──score──▶ ranked document ids

    index = InvertedIndex.build([{"id": 1, "title": "...", "summary": "...", "content_text": "...", "tags": ["..."]}])
    index.search("sleep students", ranker="bm25")   ->  [(doc_id, score), ...] best first
"""
from __future__ import annotations

import math
import re
from collections import Counter
from dataclasses import dataclass, field
from typing import Any, Iterable

TOKEN_RE = re.compile(r"[a-z0-9]+")
MAX_QUERY_TERMS = 8

# Words that carry no topic: dropped from documents and queries.
STOPWORDS = frozenset("""
a about above after again against all am an and any are as at be because been before being below between both but by
can could did do does doing down during each few for from further had has have having he her here hers him his how i if
in into is it its just me more most my no nor not now of off on once only or other our ours out over own same she should
so some such than that the their theirs them then there these they this those through to too under until up very was we
were what when where which while who whom why will with would you your yours
""".split())

# A field's term counts are multiplied by its weight: a word in the title says more about the topic than one in the body.
FIELD_WEIGHTS = {"title": 3.0, "tags": 2.0, "summary": 1.5, "content_text": 1.0}

BM25_K1 = 1.5   # how fast repeated occurrences stop adding score
BM25_B = 0.75   # how strongly long documents are penalised (0 = not at all, 1 = fully)

# Words whose final "s" is not a plural ending: left untouched by the stemmer.
STEM_EXCEPTIONS = frozenset({"news", "series", "species", "always", "perhaps", "besides", "sometimes", "physics", "economics",
                             "mathematics", "politics", "diabetes", "lens"})

_VOWELS = "aeiou"


def _is_cvc(word: str) -> bool:
    """consonant-vowel-consonant ending, e.g. 'mak', 'sav' (the shape that lost a final 'e')."""
    return (len(word) >= 3 and word[-1] not in _VOWELS + "wxy" and word[-2] in _VOWELS and word[-3] not in _VOWELS)


def _repair(stem_: str) -> str:
    if len(stem_) >= 3 and stem_[-1] == stem_[-2] and stem_[-1] not in _VOWELS + "lsz":
        return stem_[:-1]                      # running -> runn -> run
    if len(stem_) <= 4 and _is_cvc(stem_):
        return stem_ + "e"                     # making -> mak -> make
    return stem_


def stem(word: str) -> str:
    """Light suffix stemmer (Porter-inspired): plurals, -ing and -ed. 'students' and 'student' become one term."""
    if len(word) <= 3 or word.isdigit() or word in STEM_EXCEPTIONS:
        return word
    if word.endswith("ies") and len(word) > 4:
        word = word[:-3] + "y"                 # studies -> study
    elif word.endswith(("sses", "xes", "ches", "shes", "zes")):
        word = word[:-2]                       # classes -> class, boxes -> box
    elif word.endswith("s") and not word.endswith(("ss", "us", "is")):
        word = word[:-1]                       # pumps -> pump
    if word.endswith("ing") and len(word) > 5:
        return _repair(word[:-3])              # sleeping -> sleep
    if word.endswith("ed") and not word.endswith("eed") and len(word) > 4:
        return _repair(word[:-2])              # saved -> sav -> save
    return word


def tokenize(text: str | None) -> list[str]:
    """Lower-case, split on anything that is not a letter or digit, drop stop words, stem."""
    return [stem(tok) for tok in TOKEN_RE.findall((text or "").lower()) if tok not in STOPWORDS]


def query_terms(query: str) -> list[str]:
    """Distinct query terms in typing order (at most MAX_QUERY_TERMS)."""
    seen: list[str] = []
    for term in tokenize(query):
        if term not in seen:
            seen.append(term)
    return seen[:MAX_QUERY_TERMS]


@dataclass
class InvertedIndex:
    """term -> {doc_id: weighted term frequency}, plus the document statistics the rankers need."""
    postings: dict[str, dict[int, float]] = field(default_factory=dict)
    doc_len: dict[int, float] = field(default_factory=dict)       # weighted number of terms per document
    doc_norm: dict[int, float] = field(default_factory=dict)      # length of the TF-IDF vector per document
    avg_len: float = 0.0

    # ------------------------------------------------------------------ build
    @classmethod
    def build(cls, documents: Iterable[dict[str, Any]]) -> "InvertedIndex":
        index = cls()
        for doc in documents:
            index._add(doc)
        index._finish()
        return index

    def _add(self, doc: dict[str, Any]) -> None:
        doc_id = int(doc["id"])
        counts: Counter[str] = Counter()
        for name, weight in FIELD_WEIGHTS.items():
            value = doc.get(name) or ""
            text = " ".join(value) if isinstance(value, (list, tuple, set)) else str(value)
            for term in tokenize(text):
                counts[term] += weight
        self.doc_len[doc_id] = float(sum(counts.values()))
        for term, tf in counts.items():
            self.postings.setdefault(term, {})[doc_id] = tf

    def _finish(self) -> None:
        n = len(self.doc_len)
        self.avg_len = (sum(self.doc_len.values()) / n) if n else 0.0
        squares: dict[int, float] = dict.fromkeys(self.doc_len, 0.0)
        for term, docs in self.postings.items():
            idf = self.idf_tfidf(term)
            for doc_id, tf in docs.items():
                squares[doc_id] += ((1.0 + math.log(tf)) * idf) ** 2
        self.doc_norm = {doc_id: math.sqrt(v) or 1.0 for doc_id, v in squares.items()}

    # ------------------------------------------------------------------ statistics
    @property
    def size(self) -> int:
        return len(self.doc_len)

    @property
    def vocabulary(self) -> int:
        return len(self.postings)

    def df(self, term: str) -> int:
        """Document frequency: in how many documents the term occurs."""
        return len(self.postings.get(term, ()))

    def idf_bm25(self, term: str) -> float:
        df = self.df(term)
        return math.log(1.0 + (self.size - df + 0.5) / (df + 0.5)) if df else 0.0

    def idf_tfidf(self, term: str) -> float:
        df = self.df(term)
        return math.log(1.0 + self.size / df) if df else 0.0

    # ------------------------------------------------------------------ ranking
    def score_bm25(self, terms: list[str]) -> dict[int, float]:
        scores: dict[int, float] = {}
        for term in terms:
            idf = self.idf_bm25(term)
            for doc_id, tf in self.postings.get(term, {}).items():
                norm = 1.0 - BM25_B + BM25_B * (self.doc_len[doc_id] / self.avg_len if self.avg_len else 1.0)
                scores[doc_id] = scores.get(doc_id, 0.0) + idf * tf * (BM25_K1 + 1.0) / (tf + BM25_K1 * norm)
        return scores

    def score_tfidf(self, terms: list[str]) -> dict[int, float]:
        """Cosine-style TF-IDF: (1 + ln tf) * idf for the document, idf for the query, divided by the document norm."""
        scores: dict[int, float] = {}
        for term in terms:
            idf = self.idf_tfidf(term)
            for doc_id, tf in self.postings.get(term, {}).items():
                scores[doc_id] = scores.get(doc_id, 0.0) + (1.0 + math.log(tf)) * idf * idf
        return {doc_id: s / self.doc_norm[doc_id] for doc_id, s in scores.items()}

    def search(self, query: str, ranker: str = "bm25") -> list[tuple[int, float]]:
        """Documents containing at least one query term, best score first (ties: lower id first, so the order is stable)."""
        terms = query_terms(query)
        if not terms:
            return []
        scores = self.score_tfidf(terms) if ranker == "tfidf" else self.score_bm25(terms)
        return sorted(scores.items(), key=lambda pair: (-pair[1], pair[0]))

    def explain(self, query: str, doc_id: int) -> list[dict[str, Any]]:
        """Per-term breakdown of a BM25 score (used by the tests and handy when presenting)."""
        out = []
        for term in query_terms(query):
            tf = self.postings.get(term, {}).get(doc_id, 0.0)
            out.append({"term": term, "tf": tf, "df": self.df(term), "idf": round(self.idf_bm25(term), 4),
                        "score": round(self.score_bm25([term]).get(doc_id, 0.0), 4)})
        return out
