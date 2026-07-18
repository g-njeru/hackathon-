# Time Management for Hackathons

How to budget a 48-hour hackathon so you ship something that works.

---

## The Time Budget

| Phase | Time | What to do |
|---|---|---|
| **Setup** | 2-4h | Repo, Docker, DB, CI/CD, deploy pipeline, team alignment |
| **MVP** | 24-30h | Core features only — the minimum to prove the idea works |
| **Polish** | 8-12h | UI cleanup, error handling, edge cases |
| **Demo prep** | 4-6h | Slides, live demo practice, backup plans |

**Rule**: Setup should never exceed 4 hours. If it does, you're over-engineering infrastructure.

---

## Phase 1: Setup (First 4 Hours)

### Hour 1 — Scaffolding

- [ ] Create repo (or use template)
- [ ] `docker-compose up` with PG + Redis
- [ ] Scaffold FastAPI backend
- [ ] Scaffold React/Vite frontend
- [ ] Verify both run locally

### Hour 2 — Infrastructure

- [ ] Set up Supabase project (auth + DB)
- [ ] Define data contract (JSON schema)
- [ ] Push to GitHub, verify CI runs
- [ ] Deploy to Vercel/Railway (even if it's just "Hello World")

### Hour 3 — Team Alignment

- [ ] Assign roles (frontend, backend, devOps, integration)
- [ ] Set up communication channel
- [ ] Agree on branch naming and merge strategy
- [ ] Pair program for 30 minutes to share context

### Hour 4 — First Commit

- [ ] Everyone has a working local environment
- [ ] At least one endpoint returns mock data
- [ ] At least one frontend component renders
- [ ] Deploy pipeline is green

---

## Phase 2: MVP (Hours 5-34)

### Focus rules

- **One feature at a time** — finish it, then move on
- **No side quests** — if it's not in the core value proposition, skip it
- **Mock first** — don't wait for the backend to build the UI
- **Merge every 2 hours** — long-lived branches cause merge hell

### What to build

1. The **one feature** that proves your idea works
2. Basic auth (use Supabase, don't build custom)
3. Data persistence (save/load from DB)
4. Basic error handling (don't crash on bad input)

### What to skip

- Beautiful UI (ugly but working > beautiful but broken)
- Performance optimization
- Edge cases you won't demo
- Fancy animations or transitions

---

## Phase 3: Polish (Hours 35-44)

### Checklist

- [ ] UI looks intentional (consistent spacing, fonts, colors)
- [ ] Loading states exist (no blank screens)
- [ ] Error states exist (graceful failures)
- [ ] Data validates on input (don't accept garbage)
- [ ] Demo flow works end-to-end (test 3 times)

### What to polish

- Make the demo flow **smooth** — judges notice friction
- Add a few "delight" moments (micro-interactions, nice empty states)
- Clean up console.log statements and debug code
- Write a README if judges will look at the repo

---

## Phase 4: Demo Prep (Hours 45-48)

### T-4 Hours

- Walk through full demo flow as a team
- Identify weak points — what to cut, what to polish
- Assign final tasks

### T-2 Hours

- **Code freeze** — no new features
- Everyone tests their area in incognito browser
- Commit and push final state

### T-1 Hour

- Run the demo script twice
- Time it — should be **under 5 minutes**
- Prepare backup screenshots/video

### T-0

- Present
- If live demo fails, switch to backup immediately

See [DEMO_DAY_PREP.md](DEMO_DAY_PREP.md) for detailed presentation guidance.

---

## Emergency Time Savers

When you're running out of time:

| Instead of... | Do this |
|---|---|
| Custom auth system | Supabase Auth (15 min setup) |
| Complex search | PostgreSQL `LIKE` or `pg_trgm` |
| Custom charts | Recharts with simple config |
| File uploads | Supabase Storage buckets |
| Payment integration | Stripe Payment Links (no code) |
| Beautiful UI | Functional UI with consistent spacing |
| Unit tests | One E2E test of the demo path |
| Perfect error handling | Catch + display error message |

---

## The "Anchor" Rule

If a feature is taking longer than **2 hours** and it's not the core value proposition:

> **Cut it.** You can always add it in the demo as a "planned feature" slide.

The judges care about what works, not what you planned to build.
