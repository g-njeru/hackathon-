# Stack Cheatsheet

Quick reference for every tool in the stack. Each entry has a one-line explanation so you know what it does and why it's here.

---

## Frontend

| Tool | What it is | Why we use it |
|---|---|---|
| **React** | Component-based UI library for building web interfaces | Fast iteration, massive ecosystem, hireable skill |
| **React Native** | React for mobile — renders to iOS and Android from one codebase | Share logic between web and mobile |
| **Vite** | Lightning-fast build tool and dev server for frontend apps | Instant HMR, zero-config for React, replaces CRA |

---

## Backend

| Tool | What it is | Why we use it |
|---|---|---|
| **FastAPI** | Python async web framework with automatic OpenAPI docs | Fast to build, type-safe, auto-generated `/docs` endpoint |
| **Python** | General-purpose programming language | Primary backend language — readable, huge library ecosystem |

---

## Data

| Tool | What it is | Why we use it |
|---|---|---|
| **PostgreSQL** | Advanced relational database | battle-tested, supports JSON, full-text search, pgvector |
| **Redis** | In-memory data store | Caching, rate limiting, pub/sub messaging, session storage |
| **Supabase** | Managed PostgreSQL + Auth + Realtime + Storage | Firebase alternative — auth, storage, and realtime without self-hosting |

---

## Observability (FOSS LGTM Stack)

| Tool | What it is | Why we use it |
|---|---|---|
| **Loki** | Log aggregation system (like ELK but lighter) | Index labels, not text — cheap and fast log search |
| **Grafana** | Visualization and dashboarding platform | Connects to Loki, Tempo, Prometheus — single pane of glass |
| **Tempo** | Distributed tracing backend | See where time is spent across service calls |
| **Mimir** | Long-term metrics storage for Prometheus | Scalable metrics for dashboards and alerting |

---

## AI / ML

| Tool | What it is | Why we use it |
|---|---|---|
| **pgvector** | Vector similarity search extension for PostgreSQL | Store and query embeddings alongside your relational data |
| **Sentence Transformers** | Python library for generating text embeddings | Local, free, no API calls — run embeddings on your own hardware |

---

## DevOps

| Tool | What it is | Why we use it |
|---|---|---|
| **Docker** | Containerization platform | Package app + deps into a portable unit — "works on my machine" problem solved |
| **Docker Compose** | Multi-container Docker orchestration | `docker-compose up` spins up PG + Redis + app in one command |
| **GitHub Actions** | CI/CD automation built into GitHub | Lint, test, build, deploy on every push — free tier for public repos |

---

## Quick Commands

```bash
# Frontend
npm run dev              # Start Vite dev server
npm run build            # Production build

# Backend
uvicorn main:app --reload  # Start FastAPI dev server
pytest                     # Run tests

# Database
docker-compose up -d     # Start PG + Redis
psql -U postgres         # Connect to PostgreSQL

# Full stack
docker-compose up        # Everything at once
```
