# MVP Strategies for Hackathons

## Core Philosophy: Build-Measure-Learn

Rapid prototyping is not about building less code — it is about building the **right** code.

1. **Build**: Create the smallest possible high-fidelity experience that communicates your core value proposition.
2. **Measure**: Observe how real users (or judges/clients) interact with the prototype.
3. **Learn**: Determine if the core idea solves the user's problem.

---

## The "Do Not Build" Guardrails

Stop yourself from over-engineering non-core features. Use managed services instead.

| Category | Do NOT Build | Use This Instead |
|---|---|---|
| User Signups | Custom Auth Middleware | Supabase Auth / Clerk |
| Media Storage | Local File System Uploads | Supabase Buckets / S3 |
| Complex Search | ElasticSearch Clusters | PostgreSQL `LIKE` / `pg_trgm` |
| Analytics | D3.js Custom Charts | Recharts / Tremor |
| Payments | Bank Integration API | Stripe Payment Links |
| Vector Search | Self-hosted Vector DB | pgvector (you already have PG) |
| Embeddings | Custom ML Pipeline | Sentence Transformers (local, free) |
| Observability | Custom Logging | Loki + Grafana (FOSS LGTM stack) |

**Rule of thumb**: If a managed service exists and saves you >1 hour, use it.

---

## Schema-Driven Development

Define the data contract between frontend and backend in the **first 15 minutes**.

1. Agree on the JSON structure (the shape of your API responses)
2. Write it down in a shared doc or as OpenAPI spec
3. Frontend builds against hardcoded mock data matching that shape
4. Backend implements the real logic

This enables **parallel work streams** — nobody is waiting on anyone.

---

## Smoke and Mirrors Frontend

Focus on "Hardcoded Fidelity." If a backend feature is too complex to build in time, serve static, beautiful mock JSON data.

- **Goal**: Prove the value of the experience, not the robustness of the runtime engine.
- **Tools**: Use Apidog or Mirage JS to stage data before the backend is wired.
- **Pattern**: Build the UI against a hardcoded JSON object. Swap it for a real API later.

---

## The Deceptive Monolith

Instead of distributed microservices, use a **single, unified code repository** for the hackathon.

- Instantaneous updates across frontend, backend, and database schema
- No integration lag between services
- Easier to debug — everything is in one place
- Split into microservices **after** the hackathon if needed

---

## Deploy Often

> If it's not deployed on a public URL, it doesn't exist.

- Deploy on day 1, even if it's just "Hello World"
- Use automated CI/CD to maintain live feedback
- Every merge to `main` should produce a deployable artifact

---

## T-Minus 2 Hours Protocol

Two hours before the demo, switch from building to verifying.

### Checklist

1. **Code Freeze** — Stop all new feature development. No exceptions.
2. **Fresh Verification** — Execute a clean `git clone` in a new directory. Run the full setup. If something breaks, fix it now.
3. **Incognito Run** — Test all user flows in a private browser window. This catches authentication bugs and cache-related issues.
4. **Demo Script** — Walk through your presentation flow at least twice. Time it.
5. **Backup Plan** — Have screenshots or a screen recording ready if the live demo fails.
6. **Commit & Push** — Make sure all code is on `main` and the CI/CD pipeline is green.

### What can go wrong (and how to recover)

| Failure | Recovery |
|---|---|
| API is down | Show pre-recorded video or screenshots |
| Database connection fails | Have a local Docker Compose fallback |
| Frontend won't load | Use the incognito test — if it worked 10 min ago, it's a cache issue |
| Build fails on deploy | Roll back to the last working commit |
