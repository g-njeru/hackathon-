# Contributing

How to add your own cheatsheets, guides, and runnable examples.

---

## Adding a Cheatsheet

1. **Choose the right directory**
   - `frontend/` — React, Vite, React Native, CSS
   - `backend/` — FastAPI, Python, API patterns
   - `databases/` — PostgreSQL, Redis, Supabase
   - `devops/` — Docker, CI/CD, deployment
   - `observability/` — Monitoring, logging, tracing
   - `ai/` — RAG, vector DBs, ML
   - `hackathon_playbook/` — Strategy, workflows, demo prep

2. **Name the file** in `SCREAMING_SNAKE_CASE.md`
   - `FASTAPI_AUTH_PATTERNS.md`
   - `REDIS_CACHING_GUIDE.md`
   - `VERCEL_DEPLOY_STEPS.md`

3. **Follow the format**

```markdown
# Title

Brief intro — what this covers and why.

---

## Section 1

Content with code examples.

## Section 2

Tables, lists, patterns.

---

## Common Gotchas

| Issue | Fix |
|---|---|
| Problem | Solution |
```

4. **Update README.md** — Add a row to the "Quick Nav" table
5. **Commit and push**

---

## Adding a Runnable Example

1. Create a directory under the right `examples/` folder
   - `frontend/examples/your-template/`
   - `backend/examples/your-example/`
   - `databases/examples/your-setup/`

2. Include:
   - A `README.md` explaining what it does
   - A `docker-compose.yml` if it has multiple services
   - A `.env.example` with required variables
   - Instructions to run it

3. Make sure it works with `docker-compose up` or a simple command

---

## Style Guidelines

- **Markdown**: Use headers, tables, code blocks — no walls of text
- **Code examples**: Make them copy-pasteable and runnable
- **Tone**: Direct, no fluff — teammates read this under time pressure
- **Length**: Keep it short. Link to external docs if needed.
- **No comments in code**: Unless absolutely necessary

---

## What Makes a Good Cheatsheet

- **Scannable**: Headers and tables, not paragraphs
- **Actionable**: Code you can copy, commands you can run
- **Contextual**: Explains why, not just how
- **Tested**: Code examples actually work

---

## Questions?

Open an issue or ask in the team channel.
