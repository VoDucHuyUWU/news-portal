"""
Populate the database with realistic demo data.

    python -m seed.seed            # seed an empty database (skips if articles exist)
    python -m seed.seed --reset    # drop everything and seed again

Articles are original texts written for this project (no Lorem Ipsum).
Interactions (views, likes, ratings, comments, search/click logs) are SYNTHETIC
demo activity generated with a fixed random seed so the dashboards have data.
"""
from __future__ import annotations

import argparse
import html
import random
import sys
from datetime import timedelta
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from sqlalchemy import func, select  # noqa: E402

from app.config import settings  # noqa: E402
from app.database import Base, SessionLocal, engine, init_db  # noqa: E402
from app.models import (AuditLog, Category, Comment, CommentMention, Document, DocumentView, Like, Rating,  # noqa: E402
                        Report, Role, SearchClickLog, SeoMetadata, Tag, User, utcnow)
from app.routers.search import _rank_and_filter, _terms  # noqa: E402
from app.security import hash_password  # noqa: E402
from app.utils import html_to_text, slugify  # noqa: E402
from seed.articles_business_education import ARTICLES as BUSINESS_EDUCATION  # noqa: E402
from seed.articles_health_environment import ARTICLES as HEALTH_ENVIRONMENT  # noqa: E402
from seed.articles_tech_science import ARTICLES as TECH_SCIENCE  # noqa: E402
from seed.covers import COVER_VERSION, write_cover  # noqa: E402

RNG_SEED = 42
DEMO_PASSWORD = "demo1234"
ALL_ARTICLES = TECH_SCIENCE + HEALTH_ENVIRONMENT + BUSINESS_EDUCATION
DRAFT_TITLES = {"What a chip shortage teaches us about supply chains", "Groundwater: the hidden reservoir beneath our feet",
                "Choosing a university major"}

CATEGORIES = [
    ("Technology", "technology", "#3157D5", "Software, security, devices and the internet, explained clearly."),
    ("Science", "science", "#7A3FC4", "Physics, biology, space and how research works."),
    ("Health", "health", "#0F8A6A", "Evidence-based explainers on sleep, nutrition, exercise and medicine."),
    ("Environment", "environment", "#4C8A1E", "Climate, energy, oceans, wildlife and resources."),
    ("Business & Money", "business-money", "#C2571A", "Personal finance, the economy, startups and careers."),
    ("Education", "education", "#B3366B", "How we learn, study and choose what to study."),
]

USERS = [
    # username, full name, role, bio
    ("admin", "Morgan Lee", "super_admin", "Runs the platform: accounts, permissions and settings."),
    ("editor", "Priya Shah", "content_manager", "Managing editor. Plans the publishing calendar."),
    ("moderator", "Ethan Brooks", "moderator", "Keeps the comment sections friendly and spam-free."),
    ("seo", "Mai Hoang", "seo_specialist", "Looks after search visibility and audience analytics."),
    ("reader", "Jordan Ellis", "user", "Curious reader. Mostly here for science and money articles."),
    ("lan_pham", "Lan Pham", "content_manager", "Technology and security writer."),
    ("daniel_okafor", "Daniel Okafor", "content_manager", "Writes about the economy, the internet and the environment."),
    ("clara_jensen", "Clara Jensen", "content_manager", "Science and health writer with a background in biology."),
    ("tomas_silva", "Tomas Silva", "content_manager", "Covers energy, personal finance and space."),
    ("anna_k", "Anna Kowalski", "user", "Secondary school science teacher."),
    ("ben_carter", "Ben Carter", "user", "Software developer and amateur astronomer."),
    ("chi_nguyen", "Chi Nguyen", "user", "Nursing student."),
    ("david_m", "David Mensah", "user", "Small business owner, coffee enthusiast."),
    ("elif_y", "Elif Yilmaz", "user", "Urban planner interested in green cities."),
    ("farah_n", "Farah Nasser", "user", "Data analyst. Loves a good chart."),
    ("gabe_r", "Gabriel Rossi", "user", "Retired engineer."),
    ("huong_le", "Huong Le", "user", "University student studying economics."),
    ("ivan_p", "Ivan Petrov", "user", "Cyclist and climate volunteer."),
    ("julia_s", "Julia Santos", "user", "Language learner (currently Japanese)."),
    ("kenji_t", "Kenji Tanaka", "user", "Product manager at a startup."),
    ("lucia_g", "Lucia Garcia", "user", "Parent of two, learning about personal finance."),
]

COMMENTS = {
    "technology": ["This finally made it click for me, thanks.", "I switched to an authenticator app last year and never looked back.",
                   "Would love a follow-up on how this works for small companies.", "Shared this with my parents. Very clear.",
                   "Good overview. The part about recovery options is the one people forget.", "Bookmarking this for our team onboarding."],
    "science": ["Great explanation without dumbing it down.", "I am going to use this with my students next week.",
                "The diagram in my head finally makes sense now.", "Fascinating. I had no idea about the calibration part.",
                "Clear and accurate, which is rare for this topic.", "Would be great to have a reading list at the end."],
    "health": ["Helpful reminder. I definitely do not get enough sleep.", "Appreciate that this sticks to what the evidence says.",
               "The practical tips at the end are the best part.", "My doctor told me the same thing, good to see it explained.",
               "Started doing this last month and already feel the difference.", "Clear, calm and not preachy. Thank you."],
    "environment": ["Our city just started a tree planting programme, this explains why.", "I did not realise how much the ocean absorbs.",
                    "Useful facts for our neighbourhood climate group.", "Rinsing containers really does matter, our local plant says so too.",
                    "Would like to see numbers for different countries.", "Balanced article, thanks for not overselling it."],
    "business-money": ["Wish I had read this in my twenties.", "The rule of 72 trick is great.",
                       "Very practical. Setting up an automatic transfer today.", "Good reminder that profit is not the same as cash.",
                       "Clear explanation, I sent it to my younger brother.", "Would love a piece on how pensions work next."],
    "education": ["Retrieval practice changed how I study.", "Our teachers started doing low-stakes quizzes and it helps.",
                  "The Cornell method works really well for my lectures.", "Lateral reading is such a useful habit.",
                  "Sharing this with my study group.", "As a teacher, I agree with every point here."],
}
REPLIES = ["@{u} totally agree with you.", "Good point @{u}, I had the same question.", "@{u} there is a related article in this category too.",
           "Thanks @{u}, that is helpful."]
SEARCH_QUERIES = [
    ("passkeys", 9), ("password", 6), ("heat pump", 8), ("sleep", 10), ("phishing", 7), ("compound interest", 6),
    ("black hole", 5), ("crispr", 4), ("recycling", 6), ("solar panels", 6), ("inflation", 7), ("index funds", 5),
    ("spaced repetition", 5), ("battery", 5), ("vaccine", 5), ("coral reef", 3), ("emergency fund", 5), ("exercise", 6),
    ("blood pressure", 4), ("climate", 7), ("ocean", 4), ("gps", 3), ("salary", 4), ("remote work", 4),
    ("language learning", 3), ("antibiotics", 3), ("bees", 3), ("electric cars", 5), ("stress", 5), ("note taking", 3),
    ("fibre", 2), ("hydration", 3), ("peer review", 2), ("tardigrade", 2), ("startup", 3), ("cash flow", 3),
    ("misinformation", 3), ("quantum computing", 3), ("blockchain", 2), ("mortgage", 2), ("vitamin d", 2),
]


def body_to_html(body: str) -> str:
    parts = []
    for block in body.strip().split("\n\n"):
        block = " ".join(block.split())
        if block.startswith("## "):
            parts.append(f"<h2>{html.escape(block[3:])}</h2>")
        else:
            parts.append(f"<p>{html.escape(block)}</p>")
    return "\n".join(parts)


def seed(reset: bool = False) -> dict[str, int]:
    if reset:
        Base.metadata.drop_all(engine)
    init_db()
    rng = random.Random(RNG_SEED)
    now = utcnow()
    with SessionLocal() as db:
        if db.scalar(select(func.count()).select_from(Document)):
            print("Database already contains articles; use --reset to re-seed.")
            return {}
        roles = {r.name: r for r in db.execute(select(Role)).scalars()}
        pw = hash_password(DEMO_PASSWORD)
        users = {}
        for i, (username, name, role, bio) in enumerate(USERS):
            users[username] = User(username=username, email=f"{username}@margin.demo", password_hash=pw, full_name=name,
                                   bio=bio, role=roles[role], created_at=now - timedelta(days=240 - i * 5))
        db.add_all(users.values())
        cats = {slug: Category(name=n, slug=slug, color=c, description=d) for n, slug, c, d in CATEGORIES}
        db.add_all(cats.values())
        tags: dict[str, Tag] = {}
        for art in ALL_ARTICLES:
            for t in art["tags"]:
                tags.setdefault(t, Tag(name=t, slug=slugify(t)))
        db.add_all(tags.values())
        db.flush()

        # ---- documents (oldest first so ids follow publication order)
        docs: list[Document] = []
        order = list(range(len(ALL_ARTICLES)))
        rng.shuffle(order)
        for rank, idx in enumerate(order):
            art = ALL_ARTICLES[idx]
            slug = slugify(art["title"])
            content = body_to_html(art["body"])
            published_at = now - timedelta(days=(len(order) - rank) * 3, hours=rng.randint(0, 20))
            is_draft = art["title"] in DRAFT_TITLES
            doc = Document(
                title=art["title"], slug=slug, summary=art["summary"], content=content,
                content_text=html_to_text(content), category_id=cats[art["category"]].id,
                author_id=users[art["author"]].id, status="draft" if is_draft else "published",
                published_at=None if is_draft else published_at,
                created_at=published_at - timedelta(days=rng.randint(1, 4)), updated_at=published_at,
                cover_image_url=write_cover(slug, art["category"]),
                views_count=0, tags=[tags[t] for t in art["tags"]])
            docs.append(doc)
        db.add_all(docs)
        db.flush()
        (settings.media_dir / "covers" / ".version").write_text(COVER_VERSION)
        published = [d for d in docs if d.status == "published"]

        # ---- SEO metadata: complete for ~70%, partial for the rest (work for the SEO specialist)
        for d in docs:
            if rng.random() < 0.7:
                desc = d.summary if len(d.summary) <= 160 else d.summary[:157].rsplit(" ", 1)[0] + "..."
                db.add(SeoMetadata(document_id=d.id, meta_title=f"{d.title} | Margin", meta_description=desc,
                                   keywords=", ".join(t.name.lower() for t in d.tags),
                                   image_alt=f"Abstract illustration for the article '{d.title}'"))
            elif rng.random() < 0.5:
                db.add(SeoMetadata(document_id=d.id, meta_title=d.title))

        # ---- views: history over the last 30 days (+ older all-time baseline)
        view_rows = []
        for d in published:
            popularity = rng.random() ** 2
            recent = int(8 + popularity * 140)
            age_days = (now - d.published_at).days
            for _ in range(recent):
                days_ago = min(age_days, int(rng.random() ** 1.6 * 30))
                view_rows.append(DocumentView(document_id=d.id, timestamp=now - timedelta(days=days_ago, minutes=rng.randint(0, 1439)),
                                              user_id=None))
            d.views_count = recent + (int(popularity * 1800) + rng.randint(20, 200) if age_days > 30 else 0)
        db.add_all(view_rows)

        # ---- likes and ratings by members
        members = [u for u in users.values() if u.role.name == "user"] + [users["moderator"], users["seo"]]
        for d in published:
            for u in rng.sample(members, rng.randint(0, 9)):
                db.add(Like(user_id=u.id, document_id=d.id, created_at=d.published_at + timedelta(days=rng.randint(0, 20))))
            for u in rng.sample(members, rng.randint(0, 7)):
                db.add(Rating(user_id=u.id, document_id=d.id, score=rng.choices([3, 4, 5, 2], [3, 5, 4, 1])[0],
                              created_at=d.published_at + timedelta(days=rng.randint(0, 20))))

        # ---- comments with replies and @mentions
        n_comments = 0
        for d in rng.sample(published, int(len(published) * 0.75)):
            pool = COMMENTS[next(c for c in cats if cats[c].id == d.category_id)]
            thread = []
            for text in rng.sample(pool, rng.randint(1, 4)):
                author = rng.choice(members)
                c = Comment(document_id=d.id, user_id=author.id, content=text, status="visible",
                            created_at=d.published_at + timedelta(hours=rng.randint(2, 400)))
                db.add(c)
                thread.append(c)
                n_comments += 1
            db.flush()
            if len(thread) > 1 and rng.random() < 0.6:
                target = thread[0]
                replier = rng.choice([m for m in members if m.id != target.user_id])
                mentioned = db.get(User, target.user_id)
                reply = Comment(document_id=d.id, user_id=replier.id, parent_id=target.id,
                                content=rng.choice(REPLIES).format(u=mentioned.username), status="visible",
                                created_at=target.created_at + timedelta(hours=rng.randint(1, 30)))
                db.add(reply)
                db.flush()
                db.add(CommentMention(comment_id=reply.id, mentioned_user_id=mentioned.id))
                n_comments += 1
        # moderation examples: auto-flagged spam and a reported rude comment
        spam_doc, rude_doc = published[-1], published[-2]
        db.add(Comment(document_id=spam_doc.id, user_id=users["gabe_r"].id, status="pending",
                       content="Click here for FREE MONEY and a crypto giveaway!!! www.example-win.biz www.example-win.biz/now www.bonus.example",
                       flag_reason="Auto-flagged: contains spam keyword(s): free money, crypto giveaway, click here",
                       created_at=now - timedelta(hours=5)))
        rude = Comment(document_id=rude_doc.id, user_id=users["ivan_p"].id, status="visible",
                       content="Anyone who believes this is an idiot.", created_at=now - timedelta(hours=9))
        db.add(rude)
        db.flush()
        db.add(Report(reporter_id=users["anna_k"].id, target_type="comment", target_id=rude.id,
                      reason="Insulting other readers", created_at=now - timedelta(hours=7)))
        db.add(Report(reporter_id=users["farah_n"].id, target_type="document", target_id=published[5].id,
                      reason="One of the figures seems out of date, please double-check.", created_at=now - timedelta(days=1)))

        # ---- search & click logs (Phase 2 training/evaluation data)
        queries, weights = zip(*SEARCH_QUERIES)
        n_search = n_click = 0
        for _ in range(260):
            q = rng.choices(queries, weights)[0]
            when = now - timedelta(days=int(rng.random() ** 1.3 * 30), minutes=rng.randint(0, 1439))
            stmt, score = _rank_and_filter(select(Document).where(Document.status == "published"), _terms(q))
            stmt = stmt.order_by(score.desc(), Document.published_at.desc()) if score is not None else stmt
            results = db.execute(stmt.limit(20)).unique().scalars().all()
            total = len(results)
            user = rng.choice(list(users.values()) + [None] * 6)
            session = f"seed-{rng.getrandbits(48):012x}"
            log = SearchClickLog(event_type="search", user_id=user.id if user else None, session_id=session,
                                 query_string=q, filters={"sort": "relevance", "page": 1}, results_count=total,
                                 timestamp=when)
            db.add(log)
            db.flush()
            n_search += 1
            if results and rng.random() < 0.72:
                for _click in range(1 if rng.random() < 0.8 else 2):
                    rank = min(len(results), 1 + int(rng.random() ** 2.2 * len(results)))
                    db.add(SearchClickLog(event_type="click", user_id=log.user_id, session_id=session, query_string=q,
                                          filters=log.filters, search_id=log.id, clicked_doc_id=results[rank - 1].id,
                                          click_rank=rank, timestamp=when + timedelta(seconds=rng.randint(3, 90))))
                    n_click += 1
        db.add(AuditLog(actor_id=users["admin"].id, action="system.seed", entity="database",
                        detail=f"Seeded {len(docs)} articles, {len(users)} users, {n_comments} comments"))
        db.commit()
        stats = {"users": len(users), "categories": len(cats), "tags": len(tags), "documents": len(docs),
                 "published": len(published), "comments": n_comments + 2, "views": len(view_rows),
                 "searches": n_search, "clicks": n_click}
        print("Seeded:", ", ".join(f"{k}={v}" for k, v in stats.items()))
        print(f"Demo accounts (password '{DEMO_PASSWORD}'): admin, editor, moderator, seo, reader")
        return stats


def main(argv=None) -> None:
    parser = argparse.ArgumentParser(description="Seed the news portal database with demo data")
    parser.add_argument("--reset", action="store_true", help="drop all tables before seeding")
    args = parser.parse_args(argv)
    seed(reset=args.reset)


if __name__ == "__main__":
    main()
