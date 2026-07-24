# Hackathon DevOps Master Plan

A cheatsheet-driven guide for shipping fast during hackathons. Built for teams using React, FastAPI, PostgreSQL, Redis, Supabase, and Docker.

---

## Quick Nav — "I need to..."

| I need to... | Read this |
|---|---|
| **Onboard a teammate** | [TEAM_ONBOARDING.md](onboarding/TEAM_ONBOARDING.md) |
| **Know what's in the stack** | [STACK_CHEATSHEET.md](onboarding/STACK_CHEATSHEET.md) |
| **Learn git basics** | [GIT_CHEATSHEET.md](onboarding/GIT_CHEATSHEET.md) |
| **Learn linux basics** | [LINUX_CHEATSHEET.md](onboarding/LINUX_CHEATSHEET.md) |
| **Set up the dev environment** | `bash onboarding/ONBOARD_QUICKSTART.sh` |
| **Plan my hackathon time** | [TIME_MANAGEMENT.md](hackathon_playbook/TIME_MANAGEMENT.md) |
| **Avoid common mistakes** | [COMMON_MISTAKES.md](hackathon_playbook/COMMON_MISTAKES.md) |
| **Prepare for demo day** | [DEMO_DAY_PREP.md](hackathon_playbook/DEMO_DAY_PREP.md) |
| **Coordinate with my team** | [TEAM_WORKFLOWS.md](hackathon_playbook/TEAM_WORKFLOWS.md) |
| **Write API endpoints** | [API_DESIGN_PATTERNS.md](backend/API_DESIGN_PATTERNS.md) |
| **Mock data for frontend** | [MOCK_DATA_PATTERNS.md](backend/MOCK_DATA_PATTERNS.md) |
| **Use TDD with AI** | [TDD_AI_PROTOCOL.md](hackathon_playbook/TDD_AI_PROTOCOL.md) |
| **Work with AI-generated code** | [AI_DEV_WORKFLOW.md](hackathon_playbook/AI_DEV_WORKFLOW.md) |
| **Set up PostgreSQL** | [POSTGRES_CHEATSHEET.md](databases/POSTGRES_CHEATSHEET.md) |
| **Use Redis** | [REDIS_CHEATSHEET.md](databases/REDIS_CHEATSHEET.md) |
| **Set up Supabase** | [SUPABASE_QUICKSTART.md](databases/SUPABASE_QUICKSTART.md) |
| **Scaffold a React app** | [REACT_VITE_QUICKSTART.md](frontend/REACT_VITE_QUICKSTART.md) |
| **Use React Native** | [REACT_NATIVE_BASICS.md](frontend/REACT_NATIVE_BASICS.md) |
| **Style with Tailwind + shadcn** | [TAILWIND_SHADCN_GUIDE.md](frontend/TAILWIND_SHADCN_GUIDE.md) |
| **Write Docker files** | [DOCKER_CHEATSHEET.md](devops/DOCKER_CHEATSHEET.md) |
| **Set up CI/CD** | [CI_CD_WITH_GITHUB_ACTIONS.md](devops/CI_CD_WITH_GITHUB_ACTIONS.md) |
| **Deploy my app** | [DEPLOYMENT_OPTIONS.md](devops/DEPLOYMENT_OPTIONS.md) |
| **Use Nginx** | [REVERSE_PROXY_NGINX.md](devops/REVERSE_PROXY_NGINX.md) |
| **Build RAG cheaply** | [RAG_ON_A_BUDGET.md](ai/RAG_ON_A_BUDGET.md) |
| **Choose a vector DB** | [VECTOR_DB_OPTIONS.md](ai/VECTOR_DB_OPTIONS.md) |
| **Set up monitoring (LGTM)** | [LGTM_STACK_GUIDE.md](observability/LGTM_STACK_GUIDE.md) |
| **Set up monitoring (OpenObserve)** | [OPENOBSERVE_GUIDE.md](observability/OPENOBSERVE_GUIDE.md) |
| **Get a quick dashboard** | [QUICK_MONITORING_SETUP.md](observability/QUICK_MONITORING_SETUP.md) |
| **Scan for vulnerabilities** | [FOSS_SECURITY_STACK.md](security/FOSS_SECURITY_STACK.md) |
| **Prepare for production launch** | [PRODUCTION_CHECKLIST.md](production/PRODUCTION_CHECKLIST.md) |
| **Set up a remote dev env** | [ZERO_GUI_PDE.md](devops/ZERO_GUI_PDE.md) |
| **System design patterns** | [architecture/](architecture/) |

---

## The Stack

| Layer | Tool | Purpose |
|---|---|---|
| Frontend | React + Vite | Web UI |
| Mobile | React Native | iOS/Android |
| Styling | Tailwind CSS + shadcn/ui | Fast, consistent UI |
| Backend | FastAPI (Python) | API server |
| Database | PostgreSQL | Primary data store |
| Cache | Redis | Caching, sessions, queues |
| Auth + Storage | Supabase | Managed auth, storage, realtime |
| Containers | Docker + Compose | Local dev, deployment |
| CI/CD | GitHub Actions | Automated pipelines |
| Monitoring | Grafana + Loki + Tempo | Logs, metrics, traces |

---

## Get Started in 5 Minutes

```bash
# Clone the repo
git clone <repo-url>
cd hackathon

# One-command setup
bash onboarding/ONBOARD_QUICKSTART.sh

# Or manually:
cp .env.example .env          # Edit with your values
docker-compose up -d           # Start everything
```

- Frontend: http://localhost:5173
- Backend: http://localhost:8000
- API docs: http://localhost:8000/docs

---

## How to Use This Repo

Three ways to use this repo depending on your goal:

### Use as Template (recommended for new hackathons)

Creates a clean copy with no commit history. Your project, your repo.

1. Click **Use this template** at the top of the repo page
2. Name your new repo
3. Start fresh with the full structure and cheatsheets

### Fork

Keeps a connection to the original repo. Good if you want to contribute back or pull future updates.

```bash
# Fork via GitHub CLI
gh repo fork g-njeru/hackathon --clone=false

# Or fork + clone
gh repo fork g-njeru/hackathon --clone=true
cd hackathon

# Pull updates from upstream
git fetch upstream
git merge upstream/main
```

### Clone (read-only)

Just reading the cheatsheets? Clone and browse.

```bash
git clone https://github.com/g-njeru/hackathon.git
cd hackathon
```

---

## Customize for Your Stack

This repo is built for React + FastAPI + PostgreSQL + Docker. Here's how to adapt it:

### 1. Update the stack reference

Edit `onboarding/STACK_CHEATSHEET.md` to match your tools:
- Swap React for Vue/Svelte/Angular
- Swap FastAPI for Django/Express/Go
- Swap PostgreSQL for MySQL/MongoDB

### 2. Update generator scripts

Edit `scripts/generate-*.sh` to output your preferred stack:
- Change `requirements.txt` dependencies
- Swap Docker images
- Update `package.json` dependencies

### 3. Add your own cheatsheets

Create a new `.md` file in the right directory and add a row to the Quick Nav table in this README. See [CONTRIBUTING.md](CONTRIBUTING.md) for the format.

### 4. Update environment variables

Edit `.env.example` (or create one) with your service keys:
```bash
DATABASE_URL=your-db-url
REDIS_URL=your-redis-url
SUPABASE_URL=your-supabase-url
SUPABASE_KEY=your-supabase-key
```

### 5. Update docker-compose

Edit `docker-compose.yml` to add/remove services for your stack.

---

## Navigating the Repo

```
New to the team?          → onboarding/
Starting a hackathon?     → hackathon_playbook/
Building frontend?        → frontend/
Building backend?         → backend/
Need a database?          → databases/
Deploying?                → devops/
Setting up monitoring?    → observability/
Securing your app?        → security/
Going to production?      → production/
Building with AI?         → ai/
Need architecture docs?   → architecture/
Need a script?            → scripts/
```

---

## Generate a Project

Don't copy-paste from this repo — generate a fresh project:

```bash
# Backend only (FastAPI + PG + Redis)
bash scripts/generate-backend.sh my-api

# Frontend only (React/Vite + Tailwind)
bash scripts/generate-frontend.sh my-web

# Full stack (backend + frontend + DB)
bash scripts/generate-fullstack.sh my-app

# RAG pipeline (FastAPI + pgvector)
bash scripts/generate-rag.sh my-rag

# Observability stack (Grafana + Loki)
bash scripts/generate-observability.sh my-monitoring

# Just a database (PG + Redis)
bash scripts/generate-db.sh my-db
```

## Utility Scripts

```bash
# Keep free-tier services alive (prevents sleep)
bash scripts/keep-alive.sh https://my-app.fly.dev

# Check all services are running
bash scripts/status.sh

# Clean up after the hackathon
bash scripts/cleanup.sh
```

---

## Repository Structure

```
hackathon/
├── scripts/             # Generator + utility scripts
├── onboarding/          # Team onboarding guides
├── hackathon_playbook/  # Strategy, workflows, demo prep
├── frontend/            # React, Vite, React Native, Tailwind
├── backend/             # FastAPI, API patterns, mock data
├── databases/           # PostgreSQL, Redis, Supabase
├── devops/              # Docker, CI/CD, deployment, Nginx, remote dev env
├── observability/       # LGTM stack, OpenObserve, monitoring
├── security/            # Wazuh, CrowdSec, Trivy, OWASP ZAP
├── production/          # Launch checklists, compliance, payments
├── architecture/        # System design patterns
├── ai/                  # RAG, vector databases
├── reference/           # PDFs and supplementary materials
├── AGENTS.md            # AI context file
├── .gitignore
├── VERSION
└── LICENSE
```

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to add your own cheatsheets.

---

## License

MIT
