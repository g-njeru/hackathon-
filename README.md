# Hackathon DevOps Master Plan

A cheatsheet-driven guide for shipping fast during hackathons. Built for teams using React, FastAPI, PostgreSQL, Redis, Supabase, and Docker.

---

## Quick Nav — "I need to..."

| I need to... | Read this |
|---|---|
| **Onboard a teammate** | [TEAM_ONBOARDING.md](onboarding/TEAM_ONBOARDING.md) |
| **Know what's in the stack** | [STACK_CHEATSHEET.md](onboarding/STACK_CHEATSHEET.md) |
| **Set up the dev environment** | `bash onboarding/ONBOARD_QUICKSTART.sh` |
| **Plan my hackathon time** | [TIME_MANAGEMENT.md](hackathon_playbook/TIME_MANAGEMENT.md) |
| **Avoid common mistakes** | [COMMON_MISTAKES.md](hackathon_playbook/COMMON_MISTAKES.md) |
| **Prepare for demo day** | [DEMO_DAY_PREP.md](hackathon_playbook/DEMO_DAY_PREP.md) |
| **Coordinate with my team** | [TEAM_WORKFLOWS.md](hackathon_playbook/TEAM_WORKFLOWS.md) |
| **Write API endpoints** | [API_DESIGN_PATTERNS.md](backend/API_DESIGN_PATTERNS.md) |
| **Mock data for frontend** | [MOCK_DATA_PATTERNS.md](backend/MOCK_DATA_PATTERNS.md) |
| **Use TDD with AI** | [TDD_AI_PROTOCOL.md](hackathon_playbook/TDD_AI_PROTOCOL.md) |
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
| **Set up monitoring** | [LGTM_STACK_GUIDE.md](observability/LGTM_STACK_GUIDE.md) |
| **Get a quick dashboard** | [QUICK_MONITORING_SETUP.md](observability/QUICK_MONITORING_SETUP.md) |

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

## Repository Structure

```
hackathon/
├── onboarding/          # Team onboarding guides
├── hackathon_playbook/  # Strategy, workflows, demo prep
├── frontend/            # React, Vite, React Native, Tailwind
├── backend/             # FastAPI, API patterns, mock data
├── databases/           # PostgreSQL, Redis, Supabase
├── devops/              # Docker, CI/CD, deployment, Nginx
├── observability/       # LGTM stack, monitoring
├── ai/                  # RAG, vector databases
├── reference/           # PDFs and supplementary materials
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
