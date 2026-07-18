# Team Onboarding Guide

You just joined a hackathon team. Here's how to get productive in under 30 minutes.

---

## Prerequisites

Install these before the hackathon:

| Tool | Install | Verify |
|---|---|---|
| **Git** | [git-scm.com](https://git-scm.com) | `git --version` |
| **Node.js** (18+) | [nodejs.org](https://nodejs.org) or `nvm install 18` | `node --version` |
| **Python** (3.11+) | [python.org](https://python.org) or `pyenv` | `python --version` |
| **Docker** | [docker.com](https://docker.com) | `docker --version` |
| **Docker Compose** | Included with Docker Desktop | `docker-compose --version` |

---

## Quick Start (30 minutes)

### Step 1: Clone and setup (5 min)

```bash
git clone <repo-url>
cd hackathon
cp .env.example .env   # Fill in your values
```

### Step 2: Start the stack (5 min)

```bash
docker-compose up -d
```

This starts:
- PostgreSQL on `localhost:5432`
- Redis on `localhost:6379`
- FastAPI backend on `localhost:8000`
- React frontend on `localhost:5173`

### Step 3: Verify everything works (10 min)

```bash
# Backend health check
curl http://localhost:8000/health

# Frontend
open http://localhost:5173

# Database
psql -U postgres -c "\dt"
```

### Step 4: Read the key docs (10 min)

1. [STACK_CHEATSHEET.md](STACK_CHEATSHEET.md) — know what each tool does
2. [TEAM_WORKFLOWS.md](../hackathon_playbook/TEAM_WORKFLOWS.md) — how we work
3. [MVP_STRATEGIES.md](../hackathon_playbook/MVP_STRATEGIES.md) — what we're building and why

---

## Environment Variables

Copy `.env.example` to `.env` and fill in:

```bash
# Database
DATABASE_URL=postgresql://postgres:password@localhost:5432/hackathon
REDIS_URL=redis://localhost:6379

# Supabase (get from Supabase dashboard)
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key

# App
APP_ENV=development
DEBUG=true
```

**Never commit `.env`** — it's in `.gitignore`.

---

## Project Structure

```
hackathon/
├── backend/          # FastAPI app
│   ├── app/
│   │   ├── main.py
│   │   ├── routes/
│   │   ├── models/
│   │   └── schemas/
│   └── requirements.txt
├── frontend/         # React/Vite app
│   ├── src/
│   │   ├── components/
│   │   ├── pages/
│   │   └── api/
│   └── package.json
├── docker-compose.yml
└── .env.example
```

---

## Common Commands

### Frontend

```bash
cd frontend
npm install          # Install dependencies
npm run dev          # Start dev server
npm run build        # Production build
npm run lint         # Check code style
```

### Backend

```bash
cd backend
pip install -r requirements.txt  # Install dependencies
uvicorn app.main:app --reload    # Start dev server
pytest                           # Run tests
```

### Database

```bash
# Connect to PostgreSQL
psql -U postgres

# Run migrations (if using Alembic)
alembic upgrade head

# Create new migration
alembic revision --autogenerate -m "description"
```

---

## Who to Ask for What

| Question | Ask |
|---|---|
| "How do I run this?" | Check this guide, then ask the devOps person |
| "What's the API shape?" | Check the contract doc or TEAM_WORKFLOWS.md |
| "Where's the auth setup?" | Supabase dashboard — ask whoever set it up |
| "What should I work on?" | Check the task board or ask the team lead |
| "Something's broken" | Ask the person who last merged to `main` |

---

## Git Workflow

See [TEAM_WORKFLOWS.md](../hackathon_playbook/TEAM_WORKFLOWS.md) for full details.

**TL;DR**:
1. Create a branch: `git checkout -b feat/my-feature`
2. Work on your feature
3. Commit often with conventional commits
4. Push and merge to `main` every 2 hours
5. Never commit directly to `main`

---

## First 30 Minutes Checklist

- [ ] Installed: Git, Node, Python, Docker
- [ ] Cloned the repo
- [ ] Copied `.env.example` to `.env` and filled in values
- [ ] Ran `docker-compose up` — everything starts
- [ ] Verified backend responds at `localhost:8000`
- [ ] Verified frontend loads at `localhost:5173`
- [ ] Read STACK_CHEATSHEET.md
- [ ] Read TEAM_WORKFLOWS.md
- [ ] Joined the team communication channel
- [ ] Know what you're working on first
