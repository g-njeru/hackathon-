# Team Workflows

How to coordinate a team during a hackathon so nobody is blocked and the final product fits together.

---

## Schema-Driven Development

The most important thing to agree on in the first 15 minutes: **the shape of your data**.

### The Contract

Before writing any code, define the JSON structure that flows between frontend and backend:

```json
{
  "id": "uuid",
  "title": "string",
  "content": "string",
  "created_at": "ISO 8601 timestamp",
  "tags": ["string"]
}
```

Write this in a shared doc, a Slack message, or a `contracts/` directory. It doesn't matter where — it matters that **everyone sees it before building**.

### Why this works

- Frontend builds components against this shape using mock data
- Backend builds endpoints that return this shape from the database
- Nobody is waiting on anyone — parallel work streams from minute 15

### When the contract changes

If the schema needs to change mid-hackathon:
1. Announce it in the team channel
2. Update the contract document
3. Notify the person building the consuming side
4. Both sides update — the contract is the single source of truth

---

## Mock Early, Swap Later

Build the UI against hardcoded JSON that matches the agreed contract. Only wire up the real API once the backend is stable.

### Pattern

```
1. Frontend creates mock data matching the contract
2. Frontend builds all UI components against mock data
3. Backend implements endpoints returning the same shape
4. Frontend swaps mock imports for API calls
5. Done — no integration surprises
```

### Tools

- **React**: Hardcoded JSON in a `mocks/` directory or inline in the component
- **Apidog**: API mock server that simulates endpoints
- **Mirage JS**: In-browser mock API for frontend development
- **FastAPI `/docs`**: Auto-generated OpenAPI docs — use this as the contract source

---

## Git Workflow

Keep it simple. One branch per feature, merge to `main` frequently.

### Branch naming

```
feat/user-auth
fix/api-timeout
docs/readme-update
chore/docker-setup
```

### Rules

1. **Never commit directly to `main`** — always use a branch + merge (or PR if time allows)
2. **Merge at least every 2 hours** — long-lived branches cause merge hell
3. **One person owns the deploy** — only merge to `main` when the deploy is green
4. **Commit often, commit small** — easy to revert, easy to track what broke

### Commit messages (Conventional Commits)

```
feat: add user authentication via Supabase
fix: resolve race condition in document creation
docs: update stack cheatsheet with Redis section
chore: add docker-compose for local dev
```

---

## Task Assignment

### Roles (for a 4-person team)

| Role | Responsibility |
|---|---|
| **Frontend** | React/RN components, UI/UX, mock data integration |
| **Backend** | FastAPI endpoints, database schema, business logic |
| **DevOps** | Docker, CI/CD, deployment, monitoring setup |
| **Integration** | Wiring frontend ↔ backend, testing flows, demo prep |

### For smaller teams

- **2 people**: One frontend+integration, one backend+devOps
- **3 people**: Frontend, backend, devOps+integration
- **Solo**: Rotate between frontend/backend every 2 hours, devOps on day 1 only

### Pair Programming

Pair for the **first hour** to share context, then split. Re-pair during the final 2 hours for demo prep.

---

## Communication

### Check-ins

- **Every 2 hours**: 5-minute standup — what's done, what's blocked, what's next
- **T-4 hours**: Full team sync — what's working, what to cut, demo plan
- **T-2 hours**: Code freeze — nobody pushes new features

### Blockers

If you're stuck for more than **15 minutes**, ask the team. Hackathons are not the time for heroics.

---

## Demo Day Workflow

### T-4 Hours

- Walk through the full demo flow as a team
- Identify weak points — what needs polish, what needs cutting
- Assign final tasks

### T-2 Hours

- **Code freeze** — no new features
- Everyone tests their own area in incognito
- Commit and push final state

### T-1 Hour

- Run the demo script twice
- Time it — it should be **under 5 minutes**
- Prepare backup screenshots/video

### T-0

- Present
- If live demo fails, switch to backup immediately — don't debug on stage
