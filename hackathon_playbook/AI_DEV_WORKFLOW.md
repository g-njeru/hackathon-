# AI-Assisted Development Workflow

How to build software when AI writes most of the code and you review all of it.

---

## The Role Shift

| Then (coder) | Now (orchestrator) |
|---|---|
| Write code (60% of time) | Read code (60% of time) |
| Implement from specs | Write the specs |
| Debug line by line | Validate output against intent |
| Know syntax | Know architecture |
| Type fast | Decide fast |

**Your value is now in:** what to build, how to architect it, and whether the output is correct.

From Indeed Engineering (2026): "CAD didn't eliminate civil engineering; it eliminated pencil skills for drafting. Agentic coding will not eliminate software engineering but it will eliminate coding."

---

## The Workflow

```
1. Specify    →  Write a clear spec, not a clever prompt
2. Generate   →  AI writes the code
3. Review     →  3-layer approach (automated → AI → human)
4. Test       →  Automated + manual validation
5. Ship       →  With safety nets (CI, rollback, monitoring)
```

---

## 1. Specify

The spec is the contract between you and the AI. A good spec produces correct code on the first try.

### What to include

- **What** — the exact behavior expected
- **Constraints** — tech stack, patterns to follow, things to avoid
- **Input/output** — exact shapes, types, edge cases
- **Context** — what files this touches, what it must not break
- **Non-goals** — what NOT to build (prevents over-engineering)

### Spec template

```
## Task
[One sentence: what to build]

## Requirements
- [ ] [Specific requirement 1]
- [ ] [Specific requirement 2]

## Input
[What goes in — types, shapes, examples]

## Output
[What comes out — types, shapes, examples]

## Constraints
- Use [existing pattern/library] from [file]
- Do NOT [thing to avoid]
- Follow [naming convention/style] from [existing code]

## Non-goals
- [What not to build]
```

### Prompt vs. spec

| Prompt | Spec |
|---|---|
| "Add auth to the app" | "Add JWT auth with signup/login/me endpoints, bcrypt passwords, 24h token expiry" |
| "Make it faster" | "N+1 query in list_documents — add eager loading for user relation" |
| "Fix the bug" | "When user has no documents, dashboard stats returns 500 instead of empty array" |

---

## 2. Generate

Let the AI write the code. Don't micromanage the generation — focus on the output.

### Tips

- Give the AI one task at a time (don't ask for 5 features in one prompt)
- Reference existing code: "Follow the pattern in `app/routes/documents.py`"
- Tell it what NOT to do: "Do not refactor existing files"
- Keep context window focused — don't dump the entire codebase

### When to generate vs. write by hand

| Generate | Write by hand |
|---|---|
| CRUD endpoints | Authentication logic |
| UI components from mock data | Business-critical algorithms |
| Boilerplate, scaffolding | Database migrations |
| Tests for existing code | Architecture decisions |
| Documentation | Security-sensitive code |

---

## 3. Review — The 3-Layer Approach

AI review catches surface issues. Human review catches intent issues. You need both.

### Layer 1: Automated Checks (before humans see it)

```bash
# Backend: syntax + type check
python3 -m py_compile app/main.py
python3 -m py_compile app/routes/*.py

# Frontend: build check
npx vite build

# Lint + format
ruff check .
ruff format .

# Secrets scan
grep -r "password\|secret\|token\|key" --include="*.py" --include="*.js" .

# Tests
pytest
```

**Run these before every commit.** They catch 60-70% of issues in seconds.

### Layer 2: AI Code Review (first pass on PR)

Tools that review your PR automatically:

| Tool | Strength | Cost |
|---|---|---|
| **GitHub Copilot Review** | Native GitHub integration, zero config | Included with Copilot |
| **CodeRabbit** | Low false positives, learns your repo | ~$24/dev/month |
| **Greptile** | Full codebase understanding, catches cross-file issues | Paid |
| **Semgrep** | Security-focused, static analysis + AI | Free tier available |

**How to set up (GitHub example):**

1. Install the tool's GitHub app
2. Add it as a reviewer on your PRs
3. It posts inline comments automatically
4. Review the comments before human review

**Key rule:** AI review handles syntax/security/style. Humans handle intent/architecture/business logic.

### Layer 3: Human Review (what only you can do)

Questions to ask when reviewing AI-generated code:

1. **Requirement fidelity** — Does this match the actual ticket, not the AI's interpretation?
2. **Real APIs** — Does every import, function, and SDK method actually exist?
3. **Dependency provenance** — Are new packages legitimate and maintained?
4. **No hardcoded secrets** — No tokens, keys, or credentials in code or tests?
5. **Input validation** — Is external input validated at the boundary?
6. **Auth/AuthZ** — Do protected paths enforce authentication and authorization?
7. **Error handling** — Are failures handled deliberately without leaking internals?
8. **Failure tests** — Are there tests for empty states, permissions, network failures?
9. **No gate weakening** — Did the PR skip tests or loosen lint rules?
10. **Architectural fit** — Does this respect existing module boundaries and patterns?

---

## 4. Test

### What to test

| Priority | What | How |
|---|---|---|
| **High** | Auth, payments, data mutations | Integration tests + manual review |
| **Medium** | API endpoints, form validation | Automated tests |
| **Low** | UI layout, styling | Visual check |
| **Never skip** | The demo happy path | One E2E test |

### AI-assisted testing

```
# Ask AI to generate tests for existing code
"Write pytest tests for app/routes/auth.py covering:
 signup, login, me endpoint, invalid credentials, expired token"

# Ask AI to test edge cases
"Add test cases for: empty database, concurrent requests,
 malformed JWT, missing required fields"
```

### Quick smoke test

```bash
# Backend health
curl http://localhost:8000/health

# Frontend build
npx vite build

# Full integration
docker-compose up -d && sleep 3 && curl http://localhost:8000/health
```

---

## 5. Ship

### Safety nets

- **CI/CD** — automated tests + lint on every push
- **Branch protection** — no direct pushes to `main`
- **Rollback plan** — know how to revert in 30 seconds
- **Monitoring** — know when things break (see LGTM_STACK_GUIDE.md)

### Pre-ship checklist

- [ ] All automated checks pass
- [ ] AI review comments addressed
- [ ] Human review approved
- [ ] Demo happy path tested manually
- [ ] No secrets in code or commits
- [ ] `.env.example` updated (not `.env`)

---

## Risk Lanes

Not all code needs the same review intensity.

| Lane | Change Type | Review Level |
|---|---|---|
| **Green** | UI, docs, tests, small refactors, utilities | Standard approval + automated checks |
| **Yellow** | Business logic, API integrations, data transforms, background jobs | Standard + senior sign-off for subtle logic |
| **Red** | Auth, payments, PII, DB migrations, public APIs, infrastructure | AI may draft only. Require human verification + security review |

**Amazon's rule (post-March 2026 outage):** Junior/mid engineers need senior sign-off before shipping AI-assisted code.

---

## The 4 Skills That Matter Now

### 1. Problem Decomposition

Break a goal into pieces an agent can execute.

```
Bad:  "Build me a full-stack app with auth and CRUD"
Good: "1. Create User model with email + hashed_password
       2. Add /auth/signup and /auth/login endpoints
       3. Add JWT middleware
       4. Add user_id to Document model
       5. Filter documents by user_id"
```

### 2. Spec Writing

Turn intent into a durable, referenceable contract.

- Be specific about inputs, outputs, and constraints
- Reference existing patterns in the codebase
- State non-goals to prevent over-engineering

### 3. Context Engineering

Give agents the right constraints, examples, and guardrails.

```
# Bad context
"Fix the bug"

# Good context
"In app/routes/documents.py, the list_documents endpoint
returns all documents instead of filtering by user.
The user is available via get_current_user dependency.
Filter by Document.user_id == user.id, matching the
pattern in the existing get_document endpoint."
```

### 4. Ruthless Review

Read generated code critically, at volume, without rubber-stamping.

- Run automated checks first (catches 60-70%)
- Ask: "Does this match the spec?"
- Ask: "What did the AI assume that I didn't specify?"
- Ask: "What breaks if this goes to production?"

---

## Common Pitfalls

| Pitfall | Fix |
|---|---|
| AI hallucinates dependencies | Verify every import exists in the actual version |
| AI refactors what doesn't need refactoring | Tell it: "Do not touch existing files" |
| Rubber-stamping AI output | Run automated checks, then read the diff yourself |
| Skipping human review on Red-lane changes | Auth, payments, PII always need human sign-off |
| Not validating against the original spec | Re-read the spec after generation, before committing |
| AI makes silent architectural decisions | Specify architecture constraints upfront |
| Too many changes in one PR | Keep PRs under 400 lines for better review quality |

---

## Quick Reference: Prompt Templates

### Generate a feature

```
Task: [What to build]
Context: [Existing files, patterns to follow]
Input: [Data shape going in]
Output: [Data shape coming out]
Constraints: [Stack, style, things to avoid]
Non-goals: [What NOT to build]
```

### Review code

```
Review this diff for:
1. Security issues (hardcoded secrets, missing validation)
2. API correctness (real imports, correct method signatures)
3. Error handling (missing try/catch, swallowed exceptions)
4. Test coverage (are failure paths tested?)
5. Architecture fit (does this match existing patterns?)

Quote evidence from the diff for each finding.
```

### Refactor

```
Refactor [file/function] for [readability/performance/testability]
while keeping all existing tests green.
Do NOT change the public API or behavior.
```

### Debug

```
The [function/endpoint] fails with [error].
Expected: [what should happen]
Actual: [what happens]
Context: [relevant code, stack trace, conditions]
Write a failing test that reproduces this, then fix it.
```

---

## See Also

- [TDD_AI_PROTOCOL.md](TDD_AI_PROTOCOL.md) — Red-Green-Refactor with AI
- [TEAM_WORKFLOWS.md](TEAM_WORKFLOWS.md) — Git workflow, task assignment
- [JWT_AUTH_GUIDE.md](../backend/JWT_AUTH_GUIDE.md) — Auth implementation example
- [examples/my-mvp/](../examples/my-mvp/) — Working example of this workflow
