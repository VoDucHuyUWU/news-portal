# Margin: News & Digital Magazine Portal

A full-stack news portal built for **Phase 1** of the search-engine project: complete CRUD, user
authentication, role-based access control (RBAC) with four staff roles, reader engagement, basic
search and filtering, and a document store with standardised **search & click logging** ready for
Phase 2 (tokenization, inverted index, BM25/TF-IDF ranking).

| | |
|---|---|
| **Domain** | News & Digital Magazine Portal |
| **Backend** | Python 3.11+ · FastAPI (REST API, OpenAPI docs at `/docs`) · SQLAlchemy 2 |
| **Database** | PostgreSQL 16 (recommended) or SQLite (zero-setup quick start) |
| **Auth** | JWT bearer tokens, bcrypt password hashing |
| **Frontend** | React 18 + Vite, responsive black-and-gold magazine design, custom CSS (no UI framework) |
| **Tests** | 26 API tests (pytest), passing on SQLite **and** PostgreSQL |

![Home page](docs/screenshots/01-home.png)

---

## Quick start

Only **Python 3.11+** is required (the React app is already built into `backend/frontend_dist`).

```bash
git clone <this-repo-url>
cd news-portal
python run.py --install      # first time: installs Python packages, creates + seeds the DB, starts the site
python run.py                # later runs
```

The site opens at **http://127.0.0.1:8000** · API documentation at **http://127.0.0.1:8000/docs**.

| Command | Purpose |
|---|---|
| `python run.py --reset` | Wipe the database and seed the demo data again |
| `python run.py --test` | Run the test suite |
| `python run.py --port 8080 --no-browser` | Different port, do not open a browser |

### Demo accounts (password `demo1234`)

| Username | Role | What to try |
|---|---|---|
| `admin` | Super Admin | Users, roles & permissions matrix, system logs, global settings |
| `editor` | Content Manager | Create/edit/delete articles, publish/unpublish, categories & tags |
| `moderator` | Moderator | Comment review queue, reports, spam rules |
| `seo` | Data & SEO Specialist | SEO metadata editor, analytics dashboard |
| `reader` | Member | Comment, @mention, like, rate, report, edit profile |

### Using PostgreSQL

```bash
docker compose up -d                       # starts PostgreSQL 16 (see docker-compose.yml)
cp .env.example .env                       # then uncomment the DATABASE_URL line
python run.py --reset
```

Any PostgreSQL works: set `DATABASE_URL=postgresql+psycopg://USER:PASSWORD@HOST:5432/DBNAME`.
Without a `DATABASE_URL`, the app uses SQLite (`backend/news_portal.db`) so it runs with no setup.

### Frontend development (optional)

```bash
cd frontend
npm install
npm run dev        # http://localhost:5173, proxies /api to the backend on :8000
npm run build      # writes the production bundle to backend/frontend_dist
```

---

## Requirements checklist

### 4A. Client / user interface

| Requirement | Implementation |
|---|---|
| Home & directory: paginated latest items with summary snippets | Magazine front page `/` (one cover story chosen by reader attention, then Newest / Most searched / Most read, "In this issue" contents, trending searches) · **Latest** `/latest` (paginated, grouped by month) · section pages via the **Sections** menu (`/category/:slug`) and `/tag/:slug` · **Attention** `/attention` (most read, most searched, trending queries, most discussed, highest rated, most liked) · **About us** `/about` · APIs: `GET /api/front-page`, `/api/documents`, `/api/attention`, `/api/about` |
| Detail view: full content, images, author, date, views, categories, tags | `/article/:slug` · `GET /api/documents/{slug}` (increments `views_count`, records a view event) |
| Registration, login, profile management | `/register`, `/login`, `/profile` (name, email, bio, avatar, password) · `/u/:username` public profile |
| Commenting | Threaded comments and replies · `POST /api/documents/{id}/comments` |
| Rating / liking | Like toggle + 1–5 star rating · `POST .../like`, `PUT .../rating` |
| User tagging | `@username` mentions with autocomplete; stored in `comment_mentions`; "Mentions of you" on the profile |
| Keyword search (LIKE) | `/search` · `GET /api/search?q=` (case-insensitive `LIKE`/`ILIKE` over title, summary, text and tags; wildcards escaped) |
| Filters: category, tag, date range | Same endpoint: `category`, `tag`, `date_from`, `date_to`, plus sort |

### 4B. Admin interface (RBAC)

Permissions are checked **on the server for every request** (`require_permission(...)`); the admin menu only
shows tools the signed-in role can use.

| Role | Permissions | Admin pages |
|---|---|---|
| **Super Admin** | all, including `users.manage`, `roles.manage`, `logs.view`, `settings.manage` | Users (create, change role, deactivate), Roles & permissions matrix, System logs (audit + search/click), Global settings |
| **Content Manager** | `documents.manage`, `documents.publish`, `taxonomy.manage` | Articles (CRUD, HTML editor with preview, image upload), publish/unpublish, Categories & tags |
| **Moderator** | `comments.moderate`, `reports.handle` | Comment review (approve / hide / spam / delete), Reports, Spam control (keywords, link limit, rate limit, approval mode) |
| **Data & SEO Specialist** | `seo.manage`, `analytics.view` | SEO metadata (title, description, keywords, alt text, completeness score, search-result preview), Analytics dashboard |

Safeguards: the last active Super Admin cannot be demoted or deactivated, and the Super Admin role cannot lose
`users.manage`/`roles.manage`. Every administrative action and every sign-in is written to `audit_logs`.

### 5. Data schema & Phase 2 preparation

**`documents`** (all required fields present)

| Field | Notes |
|---|---|
| `id`, `title`, `summary`, `created_at`, `views_count` | as required |
| `content` | sanitised HTML (scripts and event handlers removed) |
| `content_text` | **plain-text copy** of the content, ready for the Phase 2 tokenizer |
| `category_id` | FK → `categories` |
| `tags` | many-to-many via `document_tags`; returned as a `tags` array by the API |
| `author` | `author_id` FK → `users`; returned as an `author` object by the API |
| extra | `slug`, `status` (draft/published), `published_at`, `updated_at`, `cover_image_url`; SEO fields in `seo_metadata` |

**`search_click_logs`** (one row per event)

| Field | Notes |
|---|---|
| `user_id` | NULL for guests (a per-browser `session_id` is also stored) |
| `query_string` | normalised query text |
| `clicked_doc_id` | NULL for `search` events; the clicked document for `click` events |
| `timestamp` | UTC |
| extra | `event_type` (`search`/`click`), `search_id` (links a click to its search), `click_rank` (1-based position), `results_count`, `filters` (JSON) |

Every search with a query or filter is logged, and clicking a result logs a click linked to that search. This gives
Phase 2 the data for click-through rate, average clicked rank and relevance judgements. Article views are recorded in
`document_views` for analytics.

**Seed data:** `backend/seed/` contains **60 original articles** (6 categories × 10, about 180–220 words each, written
for this project, no Lorem Ipsum), 31 tags, 21 users across all roles, and SEO metadata for about 70% of articles.
To make the dashboards meaningful, the seed also generates **synthetic demo activity** with a fixed random seed: view
history, likes, ratings, threaded comments with mentions, moderation examples, and 260 searches / ~200 clicks. These
interactions are generated, not real user data.

Full table list: `users`, `roles`, `permissions`, `role_permissions`, `categories`, `tags`, `documents`,
`document_tags`, `seo_metadata`, `comments`, `comment_mentions`, `likes`, `ratings`, `reports`, `search_click_logs`,
`document_views`, `audit_logs`, `settings` (see `backend/app/models.py`).

---

## Project structure

```
news-portal/
├── run.py                     one-command launcher
├── docker-compose.yml         PostgreSQL 16
├── .env.example
├── backend/
│   ├── app/
│   │   ├── main.py            FastAPI app, serves the API, media and the React build
│   │   ├── models.py          SQLAlchemy schema
│   │   ├── schemas.py         request/response models
│   │   ├── rbac.py            roles, permissions, default settings (single source of truth)
│   │   ├── deps.py            current user + require_permission()
│   │   ├── services.py        spam control, mentions, engagement
│   │   └── routers/           auth, users, public, search, admin_system, admin_content, admin_moderation, admin_seo
│   ├── seed/                  60 articles + seed script
│   ├── tests/                 API, RBAC, search-log and seed tests
│   ├── frontend_dist/         production build of the React app (committed so Python alone can run the site)
│   └── requirements.txt
├── frontend/                  React + Vite source
└── docs/screenshots/
```

## Tests

```bash
python run.py --test                     # SQLite
cd backend && TEST_DATABASE_URL=postgresql+psycopg://user:pass@localhost:5432/test_db python -m pytest -q
```

The suite covers registration/login/profile, an RBAC matrix (every role against every admin endpoint, plus anonymous
access), permission assignment, last-admin protection, settings, document CRUD and publishing, XSS sanitising, taxonomy,
pagination, filters, LIKE escaping, search and click logging, likes, ratings, comments, mentions, spam detection, rate
limiting, reports, SEO metadata, analytics and the seed dataset.

## Phase 2 hook

`backend/app/routers/search.py` isolates ranking in `_rank_and_filter()`. Phase 2 can replace it with an inverted index
built from `documents.content_text` and BM25/TF-IDF scoring without changing the API, the frontend or the log format.

## Limitations

- Basic search uses SQL `LIKE`, so there is no stemming, typo tolerance or relevance scoring beyond title matches (by design for Phase 1).
- The SPA sets page titles and meta descriptions on the client; server-side rendering would be needed for full SEO.
- Seeded interactions are synthetic; analytics become representative only with real traffic.
- JWTs are stored in `localStorage` for simplicity; change `SECRET_KEY` before any real deployment.

## Screenshots

| | |
|---|---|
| ![Sections menu](docs/screenshots/01b-sections-menu.png) | ![Article](docs/screenshots/02-article.png) |
| ![Latest](docs/screenshots/14-latest.png) | ![Attention](docs/screenshots/15-attention.png) |
| ![About us](docs/screenshots/16-about.png) | ![Search](docs/screenshots/04-search.png) |
| ![Content manager](docs/screenshots/05-admin-content-manager.png) | ![Moderator](docs/screenshots/06-admin-moderator.png) |
| ![Analytics](docs/screenshots/07-admin-seo-analytics.png) | ![Roles](docs/screenshots/08-admin-super-roles.png) |
| ![Search & click log](docs/screenshots/10-admin-search-click-log.png) | ![Mobile](docs/screenshots/12-mobile-home.png) |
