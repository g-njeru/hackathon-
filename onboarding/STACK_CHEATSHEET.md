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

## Observability

| Tool | What it is | Why we use it |
|---|---|---|
| **OpenObserve** | Unified observability engine (logs, metrics, traces) | Single Rust binary, 40x Parquet compression, SQL queries — replaces full LGTM stack |
| **Loki** | Log aggregation system (like ELK but lighter) | Index labels, not text — cheap and fast log search |
| **Grafana** | Visualization and dashboarding platform | Connects to Loki, Tempo, Prometheus — single pane of glass |
| **Tempo** | Distributed tracing backend | See where time is spent across service calls |
| **Mimir** | Long-term metrics storage for Prometheus | Scalable metrics for dashboards and alerting |

See [OPENOBSERVE_GUIDE.md](../observability/OPENOBSERVE_GUIDE.md) for OpenObserve setup. See [LGTM_STACK_GUIDE.md](../observability/LGTM_STACK_GUIDE.md) for the full Grafana/Loki stack.

---

## Security (FOSS)

| Tool | What it is | Why we use it |
|---|---|---|
| **Wazuh** | Host SIEM/XDR — endpoint threat detection | File integrity monitoring, OS CVE scanning, active response |
| **CrowdSec** | Automated intrusion blocking | Crowdsourced threat intel — auto-bans brute-force and bot IPs |
| **Trivy** | Container & dependency vulnerability scanner | Scans Docker images, requirements.txt, package.json for CVEs |
| **OWASP ZAP** | API & web app security scanner | Automated pen testing for auth flaws, SQLi, CORS, data leakage |

See [FOSS_SECURITY_STACK.md](../security/FOSS_SECURITY_STACK.md) for setup and usage.

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
