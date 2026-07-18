# React + Vite Quickstart

Scaffold, develop, and build a React app with Vite.

---

## Setup

### Create project

```bash
npm create vite@latest frontend -- --template react
cd frontend
npm install
npm run dev
```

### Project structure

```
frontend/
├── public/              # Static assets
├── src/
│   ├── components/      # Reusable components
│   ├── pages/           # Page components
│   ├── api/             # API client functions
│   ├── hooks/           # Custom React hooks
│   ├── mocks/           # Mock data
│   ├── App.jsx          # Root component
│   ├── main.jsx         # Entry point
│   └── index.css        # Global styles
├── index.html           # HTML template
├── vite.config.js       # Vite configuration
└── package.json
```

---

## Common Commands

```bash
npm run dev          # Start dev server (http://localhost:5173)
npm run build        # Production build (output: dist/)
npm run preview      # Preview production build
npm run lint         # Lint with ESLint
```

---

## Environment Variables

Create `.env` in the frontend root:

```bash
VITE_API_URL=http://localhost:8000
VITE_SUPABASE_URL=https://xxxx.supabase.co
VITE_SUPABASE_ANON_KEY=eyJ...
```

Access in code:

```javascript
const apiUrl = import.meta.env.VITE_API_URL
```

**Prefix with `VITE_`** — only these are exposed to the client.

---

## Project Patterns

### Fetching data

```javascript
// src/api/documents.js
const API_URL = import.meta.env.VITE_API_URL

export async function fetchDocuments() {
  const res = await fetch(`${API_URL}/documents`)
  if (!res.ok) throw new Error('Failed to fetch')
  return res.json()
}

export async function createDocument(data) {
  const res = await fetch(`${API_URL}/documents`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(data)
  })
  if (!res.ok) throw new Error('Failed to create')
  return res.json()
}
```

### Custom hook for data fetching

```javascript
// src/hooks/useDocuments.js
import { useState, useEffect } from 'react'
import { fetchDocuments } from '../api/documents'

export function useDocuments() {
  const [documents, setDocuments] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  useEffect(() => {
    fetchDocuments()
      .then(setDocuments)
      .catch(setError)
      .finally(() => setLoading(false))
  }, [])

  return { documents, loading, error }
}
```

### Page component

```javascript
// src/pages/Documents.jsx
import { useDocuments } from '../hooks/useDocuments'

export function Documents() {
  const { documents, loading, error } = useDocuments()

  if (loading) return <div>Loading...</div>
  if (error) return <div>Error: {error.message}</div>

  return (
    <div>
      <h1>Documents</h1>
      {documents.map(doc => (
        <div key={doc.id}>{doc.title}</div>
      ))}
    </div>
  )
}
```

---

## Routing (React Router)

```bash
npm install react-router-dom
```

```javascript
// src/App.jsx
import { BrowserRouter, Routes, Route } from 'react-router-dom'
import { Documents } from './pages/Documents'
import { DocumentDetail } from './pages/DocumentDetail'

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Documents />} />
        <Route path="/documents/:id" element={<DocumentDetail />} />
      </Routes>
    </BrowserRouter>
  )
}
```

---

## Vite Configuration

```javascript
// vite.config.js
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    proxy: {
      '/api': {
        target: 'http://localhost:8000',
        changeOrigin: true,
      }
    }
  }
})
```

With the proxy, you can call `fetch('/api/documents')` without CORS issues.

---

## Deployment

### Vercel

1. Push to GitHub
2. Go to vercel.com, import the repo
3. Set environment variables
4. Deploy — automatic on every push to `main`

### Build for any static host

```bash
npm run build    # Output in dist/
# Upload dist/ to any static host
```

---

## Common Gotchas

| Issue | Fix |
|---|---|
| CORS errors in dev | Use Vite proxy or add CORS middleware to FastAPI |
| Environment variables not loading | Prefix with `VITE_`, restart dev server |
| Stale state after navigation | Use React Router's `key` prop to force remount |
| API calls fail on deploy | Check `VITE_API_URL` is set correctly |
