# Mock Data Patterns

From the PDF: "Build the UI against a hardcoded JSON object. Swap it for a real API later."

---

## Why Mock Early

- Frontend is **blocked** waiting for backend endpoints
- Mocking lets frontend build **in parallel** with backend
- You discover contract mismatches **before** integration
- Reduces "works on my machine" integration bugs

---

## Pattern: FastAPI Mock Endpoint

### Option 1: Hardcoded mock route

```python
# routes/mock_documents.py
from fastapi import APIRouter

router = APIRouter(prefix="/mock", tags=["mock"])

MOCK_DOCUMENTS = [
    {
        "id": "doc-1",
        "title": "Getting Started",
        "content": "This is a sample document.",
        "tags": ["intro", "tutorial"],
        "created_at": "2024-01-15T10:30:00Z"
    },
    {
        "id": "doc-2",
        "title": "Advanced Topics",
        "content": "Deep dive into the system.",
        "tags": ["advanced"],
        "created_at": "2024-01-16T14:00:00Z"
    }
]

@router.get("/documents")
async def mock_list_documents():
    return MOCK_DOCUMENTS

@router.get("/documents/{doc_id}")
async def mock_get_document(doc_id: str):
    for doc in MOCK_DOCUMENTS:
        if doc["id"] == doc_id:
            return doc
    return {"detail": "Not found"}
```

### Option 2: Conditional mock vs real

```python
# config.py
import os
USE_MOCK_DATA = os.getenv("USE_MOCK_DATA", "true").lower() == "true"

# routes/documents.py
from config import USE_MOCK_DATA
from routes.mock_documents import MOCK_DOCUMENTS

@router.get("/documents")
async def list_documents():
    if USE_MOCK_DATA:
        return MOCK_DOCUMENTS
    # Real implementation
    return await db.execute(select(Document))
```

Toggle with environment variable:
```bash
USE_MOCK_DATA=false uvicorn app.main:app --reload
```

---

## Pattern: Frontend Mock Data

### React: Mock data file

```javascript
// src/mocks/documents.js
export const MOCK_DOCUMENTS = [
  {
    id: "doc-1",
    title: "Getting Started",
    content: "This is a sample document.",
    tags: ["intro", "tutorial"],
    created_at: "2024-01-15T10:30:00Z"
  },
  {
    id: "doc-2",
    title: "Advanced Topics",
    content: "Deep dive into the system.",
    tags: ["advanced"],
    created_at: "2024-01-16T14:00:00Z"
  }
]
```

### React: Mock API hook

```javascript
// src/api/useDocuments.js
import { MOCK_DOCUMENTS } from '../mocks/documents'

const USE_MOCK = import.meta.env.VITE_USE_MOCK === 'true'

export async function fetchDocuments() {
  if (USE_MOCK) {
    // Simulate network delay
    await new Promise(r => setTimeout(r, 300))
    return MOCK_DOCUMENTS
  }

  const res = await fetch('/api/documents')
  if (!res.ok) throw new Error('Failed to fetch')
  return res.json()
}
```

### Swap to real API

When the backend is ready:
1. Set `VITE_USE_MOCK=false` in `.env`
2. Update `.env` with real API URL
3. Done — no code changes needed

---

## Pattern: Apidog (API Mock Server)

1. Create a new project in Apidog
2. Define your API endpoints and response schemas
3. Apidog generates a mock server URL
4. Point your frontend at the mock URL

```javascript
// .env
VITE_API_URL=https://your-mock.apidog.io/m1-xxxxx
```

When the real API is ready, swap the URL.

---

## Pattern: Mirage JS (In-Browser Mock)

```javascript
// src/mirage/server.js
import { createServer, Model } from 'miragejs'

export function makeServer({ environment = 'development' } = {}) {
  return createServer({
    environment,

    models: {
      document: Model,
    },

    seeds(server) {
      server.create('document', { title: 'Getting Started', content: 'Hello' })
      server.create('document', { title: 'Advanced Topics', content: 'Deep dive' })
    },

    routes() {
      this.namespace = 'api'

      this.get('/documents', (schema) => {
        return schema.documents.all()
      })

      this.get('/documents/:id', (schema, request) => {
        return schema.documents.find(request.params.id)
      })

      this.post('/documents', (schema, request) => {
        const attrs = JSON.parse(request.requestBody)
        return schema.documents.create(attrs)
      })
    },
  })
}
```

---

## Mock Data Best Practices

1. **Match the contract** — Mock data must match the JSON schema exactly
2. **Include edge cases** — Empty strings, null values, empty arrays
3. **Use realistic data** — Not "foo", "bar", "test" — use plausible values
4. **Cover all states** — Empty list, single item, many items, error states
5. **Delete mocks after integration** — Don't leave mock code in production

---

## When to Mock vs Build Real

| Scenario | Mock | Build Real |
|---|---|---|
| UI development before backend is ready | ✅ | |
| Third-party API integration | | ✅ |
| Complex business logic | | ✅ |
| Demo data for judges | ✅ | |
| Quick prototype | ✅ | |
| Final 2 hours before demo | | ✅ |
