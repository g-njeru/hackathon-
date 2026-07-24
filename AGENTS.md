# AGENTS.md

## What This Repo Is

Hackathon DevOps Master Plan — a cheatsheet-driven reference for shipping fast during hackathons. Contains guides, scripts, generator tools, and one example full-stack app. Evolving into a broader reference covering security, production readiness, and system architecture.

## Repo Structure

```
hackathon/
├── onboarding/          # Team setup guides, stack/git/linux basics
├── hackathon_playbook/  # Strategy, time mgmt, demo prep, common mistakes
├── frontend/            # React, Vite, React Native, Tailwind + shadcn
├── backend/             # FastAPI API design patterns, mock data
├── databases/           # PostgreSQL, Redis, Supabase cheatsheets
├── devops/              # Docker, CI/CD, deployment, Nginx, remote dev env
├── observability/       # LGTM stack + OpenObserve
├── security/            # FOSS security tools (Wazuh, CrowdSec, Trivy, ZAP)
├── production/          # Launch checklists, compliance, payments
├── architecture/        # System design patterns (WIP)
├── ai/                  # RAG pipelines, vector DB options
├── reference/           # PDFs and supplementary materials
├── scripts/             # Generator + utility scripts
├── examples/my-mvp/     # Reference full-stack app (FastAPI + React + PG + Redis)
└── README.md            # Main entry point with Quick Nav table
```

## Key Commands

```bash
# One-command team setup
bash onboarding/ONBOARD_QUICKSTART.sh

# Generate a new project
bash scripts/generate-backend.sh my-api
bash scripts/generate-frontend.sh my-web
bash scripts/generate-fullstack.sh my-app
bash scripts/generate-rag.sh my-rag
bash scripts/generate-observability.sh my-monitoring
bash scripts/generate-db.sh my-db

# Check services
bash scripts/status.sh

# Clean up
bash scripts/cleanup.sh
```

## Stack

React + Vite | React Native | FastAPI (Python) | PostgreSQL 16 | Redis 7 | Supabase | Docker Compose | GitHub Actions | OpenObserve | Grafana/Loki | Wazuh | CrowdSec | Trivy | OWASP ZAP

## Conventions

- Cheatsheet naming: `SCREAMING_SNAKE_CASE.md`
- Cheatsheet format: title, intro, sections with code, Common Gotchas table at end
- Style: scannable, actionable, copy-pasteable code, direct tone, no fluff
- New cheatsheets: add to appropriate subdirectory + add row to README Quick Nav table
- Runnable examples need: `README.md`, `docker-compose.yml` (if multi-service), `.env.example`

## Gotchas

- `.gitignore` is minimal at root — subdirectories handle their own ignores
- `examples/my-mvp/` is a reference app, not the main repo output
- `repomix-output.xml` exists as a full-repo XML dump for AI ingestion
- `career/` directory is gitignored — personal content, not for public repo
- Free services (Fly.io etc.) may sleep — use `scripts/keep-alive.sh` to prevent it
