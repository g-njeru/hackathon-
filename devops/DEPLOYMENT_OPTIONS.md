# Deployment Options

Compare deployment platforms and choose the right one for your hackathon project.

---

## Quick Comparison

| Platform | Best for | Free tier | Deploy speed | Complexity |
|---|---|---|---|---|
| **Vercel** | Frontend + serverless API | 100GB bandwidth | ~30s | Low |
| **Railway** | Full-stack apps | $5 credit/month | ~1min | Low |
| **Fly.io** | Docker apps, global edge | 3 shared VMs | ~2min | Medium |
| **Render** | Full-stack + databases | 750 hrs/month | ~2min | Low |
| **Supabase** | Backend-as-a-service | 2 projects | ~1min | Low |

---

## Vercel (Frontend + Serverless)

### Best for
- React/Vite/Next.js frontends
- Serverless API routes (Next.js API routes)
- Static sites

### Setup

```bash
npm i -g vercel
cd frontend
vercel
```

### Vercel + FastAPI (separate backend)

1. Deploy frontend to Vercel
2. Deploy backend to Railway/Fly.io
3. Set `VITE_API_URL` env var in Vercel to point to backend

### Limits
- 100GB bandwidth/month (free)
- 10s function timeout (free), 60s (pro)
- No persistent filesystem

---

## Railway (Full-Stack)

### Best for
- Full-stack apps (backend + database)
- Quick deploys from GitHub
- Projects needing persistent storage

### Setup

1. Go to [railway.app](https://railway.app)
2. Connect GitHub repo
3. Railway auto-detects your stack
4. Set environment variables
5. Deploy

### Dockerfile

Railway uses your Dockerfile or auto-detects:
- `requirements.txt` → Python
- `package.json` → Node.js
- `Dockerfile` → Docker

### Limits
- $5 credit/month (free)
- 512MB RAM, 1 vCPU (free)
- Sleeps after inactivity (free)

---

## Fly.io (Docker Apps)

### Best for
- Docker-based apps
- Global edge deployment (low latency)
- WebSocket-heavy apps

### Setup

```bash
# Install flyctl
curl -L https://fly.io/install.sh | sh

# Login
fly auth login

# Launch (creates fly.toml)
fly launch

# Deploy
fly deploy
```

### fly.toml

```toml
app = "my-hackathon-app"

[build]

[http_service]
  internal_port = 8000
  force_https = true

  [http_service.concurrency]
    type = "connections"
    hard_limit = 25
    soft_limit = 20

[[vm]]
  cpu_kind = "shared"
  cpus = 1
  memory_mb = 256
```

### Limits
- 3 shared VMs (free)
- 160GB bandwidth/month (free)
. Sleeps after inactivity (free)

---

## Render (Full-Stack)

### Best for
- Full-stack apps with managed PostgreSQL
- Static sites
- Background workers

### Setup

1. Go to [render.com](https://render.com)
2. Connect GitHub repo
3. Choose: Web Service, Static Site, or PostgreSQL
4. Set environment variables
5. Deploy

### Limits
- 750 hrs/month (free)
- 512MB RAM (free)
- Spins down after inactivity (free)

---

## Supabase (Backend-as-a-Service)

### Best for
- Projects that don't need a custom backend
- Auth + database + storage in one
- Realtime features

### What you get
- PostgreSQL database
- Auth (email, OAuth, magic links)
- File storage
- Realtime subscriptions
- Edge functions (serverless)

### Limits
- 2 free projects
- 500MB database storage
- 1GB file storage
- 50,000 monthly active users (auth)

---

## Recommendation by Project Type

| Project type | Frontend | Backend | Database |
|---|---|---|---|
| **Web app (SPA)** | Vercel | Railway | Railway PostgreSQL |
| **Web app (SSR)** | Vercel (Next.js) | Vercel API routes | Supabase |
| **API-only** | — | Fly.io | Fly.io PostgreSQL |
| **Full-stack managed** | Vercel | Supabase | Supabase |
| **Mobile + Web** | Vercel | Railway | Supabase |

---

## Hackathon Deployment Checklist

1. [ ] Deploy on day 1 (even if it's just "Hello World")
2. [ ] Set environment variables in the deployment platform
3. [ ] Verify the deploy URL works
4. [ ] Set up automatic deploys on push to `main`
5. [ ] Test the full flow on the deployed URL
6. [ ] Share the URL with your team
7. [ ] Before demo: verify the deploy is still working

---

## Common Gotchas

| Issue | Fix |
|---|---|
| Frontend can't reach backend | Check CORS, verify API URL in env vars |
| Deploy works locally but not in production | Check environment variables are set |
| App sleeps after inactivity | Upgrade to paid tier or add a health check ping |
| Slow cold starts | Use edge functions (Vercel) or keep-alive pings |
| Database connection fails | Use connection pooling, check firewall rules |
