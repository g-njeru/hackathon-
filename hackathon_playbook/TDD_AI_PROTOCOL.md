# TDD & AI-Assisted Development Protocol

Using TDD in a hackathon isn't about 100% coverage — it's about using tests as **specifications for AI coding assistants**. AI models struggle to hold complex requirements in context. A test acts as a hard constraint that keeps the AI grounded and prevents feature bloat or hallucinations.

---

## The "AI-Driven" Red-Green-Refactor Protocol

### 1. Red — Prompt the Test

Don't ask the AI to write a feature blind. Instead, prompt with the test first:

```
I am writing a get_legal_document function.
Create a failing test using pytest that expects a dictionary output
with keys id, title, and content when given a valid ID.
```

The test becomes the **specification**. It tells the AI exactly what to build.

### 2. Green — Constrain the Logic

Give the test to the AI and prompt:

```
Write only the minimum functional code needed to make this test pass.
```

This prevents the AI from over-engineering unnecessary edge cases. The test is the boundary.

### 3. Refactor — Polish

Once the test is green:

```
Refactor this logic for readability and execution speed
while keeping the test suite green.
```

The tests act as a safety net — the AI can restructure freely without breaking anything.

---

## Strategic Testing Matrix

In an MVP sprint, you do not have time for 100% coverage. Divide your testing purposefully.

### Use TDD For (High Control)

- **Business Logic** — Data transformation pipelines, text processing, calculations
- **API Endpoints** — Ensure FastAPI routes strictly match the JSON schema contracts
- **Regression Bugs** — Replicate a crash with a quick test before fixing it to lock in the solution

### Skip TDD / Spike First (High Speed)

- **UI/UX Shells** — React components, responsive layouts, CSS adjustments
- **Exploratory Tech Spikes** — First-time integrations with a third-party API where capabilities are unknown
- **High-Volatility Features** — Exploratory features changing hourly based on immediate feedback

---

## The Inverted Testing Pyramid for MVPs

Traditional advice: lots of unit tests, fewer integration tests, one E2E test. For hackathons, **flip it**.

```
        /  E2E  \          ← 1 test: your demo happy path
       /----------\
      / Integration \      ← Bulk of your tests: API ↔ DB
     /----------------\
    /    Unit Tests     \   ← Only for complex algorithms
   /--------------------\
```

### Integration Tests (Bulk Value)

Test the integration between your API endpoints and your data tier. This gives you the **highest system confidence for the lowest amount of test code written**.

```python
# Example: FastAPI + PostgreSQL integration test
async def test_create_and_read_document(client, db):
    response = await client.post("/docs", json={"title": "Test", "content": "Hello"})
    assert response.status_code == 201
    doc_id = response.json()["id"]

    response = await client.get(f"/docs/{doc_id}")
    assert response.status_code == 200
    assert response.json()["title"] == "Test"
```

### Unit Tests (Targeted)

Limit these exclusively to **complex core algorithms** — matching engines, parsing logic, data transformations with edge cases.

### End-to-End Test (The Demo Path)

Write **exactly one** automated E2E test (Playwright or Cypress) that follows your presentation flow. If this stays green, your application is safe to demo.

```python
# Example: Playwright demo path test
def test_demo_happy_path(page):
    page.goto("http://localhost:3000")
    page.click("text=Get Started")
    page.fill("input[name=query]", "What is this app?")
    page.click("button[type=submit]")
    assert page.locator(".response").is_visible()
```

---

## The "Anchor" Exception

If a requirement shifts mid-hackathon and an old test begins slowing your momentum down:

> **Delete the test.** Do not fight your own tests when under a deadline.

Tests are tools, not obligations. If a test is no longer aligned with the current direction of the project, remove it without guilt. You can always write a new one later that matches the new requirements.

---

## Quick Reference: AI Prompt Templates

| Phase | Prompt Template |
|---|---|
| **Red** | "Write a failing test for [function] that expects [input] → [output]" |
| **Green** | "Write only the minimum code to make this test pass" |
| **Refactor** | "Refactor this for readability while keeping tests green" |
| **Edge cases** | "Add test cases for [edge case] and update the implementation" |
| **Bug fix** | "Write a failing test that reproduces [bug], then fix it" |
