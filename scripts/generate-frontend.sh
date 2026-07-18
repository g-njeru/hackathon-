#!/bin/bash
set -e

PROJECT_NAME="${1:-my-frontend}"

echo "Generating $PROJECT_NAME..."

mkdir -p "$PROJECT_NAME/src/api" "$PROJECT_NAME/src/hooks" "$PROJECT_NAME/src/mocks" "$PROJECT_NAME/src/pages" "$PROJECT_NAME/src/components/ui" "$PROJECT_NAME/public"

cat > "$PROJECT_NAME/package.json" << 'EOF'
{
  "name": "hackathon-frontend",
  "private": true,
  "version": "0.1.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "lint": "eslint ."
  },
  "dependencies": {
    "react": "^18.3.1",
    "react-dom": "^18.3.1",
    "react-router-dom": "^6.26.0"
  },
  "devDependencies": {
    "@types/react": "^18.3.3",
    "@types/react-dom": "^18.3.0",
    "@vitejs/plugin-react": "^4.3.1",
    "autoprefixer": "^10.4.20",
    "postcss": "^8.4.41",
    "tailwindcss": "^3.4.10",
    "vite": "^5.4.0"
  }
}
EOF

cat > "$PROJECT_NAME/vite.config.js" << 'EOF'
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
EOF

cat > "$PROJECT_NAME/tailwind.config.js" << 'EOF'
/** @type {import('tailwindcss').Config} */
export default {
  content: ["./index.html", "./src/**/*.{js,ts,jsx,tsx}"],
  theme: {
    extend: {},
  },
  plugins: [],
}
EOF

cat > "$PROJECT_NAME/postcss.config.js" << 'EOF'
export default {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
EOF

cat > "$PROJECT_NAME/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Hackathon</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
  </body>
</html>
EOF

cat > "$PROJECT_NAME/src/main.jsx" << 'EOF'
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App'
import './index.css'

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)
EOF

cat > "$PROJECT_NAME/src/index.css" << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;
EOF

cat > "$PROJECT_NAME/src/App.jsx" << 'EOF'
import { BrowserRouter, Routes, Route } from 'react-router-dom'
import Documents from './pages/Documents'

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Documents />} />
      </Routes>
    </BrowserRouter>
  )
}
EOF

cat > "$PROJECT_NAME/src/api/documents.js" << 'EOF'
const API_URL = import.meta.env.VITE_API_URL || ''
const USE_MOCK = import.meta.env.VITE_USE_MOCK === 'true'

import { MOCK_DOCUMENTS } from '../mocks/documents'

export async function fetchDocuments() {
  if (USE_MOCK) {
    await new Promise(r => setTimeout(r, 300))
    return MOCK_DOCUMENTS
  }
  const res = await fetch(`${API_URL}/api/documents`)
  if (!res.ok) throw new Error('Failed to fetch')
  return res.json()
}

export async function createDocument(data) {
  if (USE_MOCK) {
    await new Promise(r => setTimeout(r, 300))
    return { id: 'mock-' + Date.now(), ...data, created_at: new Date().toISOString(), updated_at: new Date().toISOString() }
  }
  const res = await fetch(`${API_URL}/api/documents`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(data)
  })
  if (!res.ok) throw new Error('Failed to create')
  return res.json()
}
EOF

cat > "$PROJECT_NAME/src/hooks/useDocuments.js" << 'EOF'
import { useState, useEffect } from 'react'
import { fetchDocuments } from '../api/documents'

export default function useDocuments() {
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
EOF

cat > "$PROJECT_NAME/src/mocks/documents.js" << 'EOF'
export const MOCK_DOCUMENTS = [
  {
    id: "doc-1",
    title: "Getting Started",
    content: "This is a sample document.",
    created_at: "2024-01-15T10:30:00Z",
    updated_at: "2024-01-15T10:30:00Z"
  },
  {
    id: "doc-2",
    title: "Advanced Topics",
    content: "Deep dive into the system.",
    created_at: "2024-01-16T14:00:00Z",
    updated_at: "2024-01-16T14:00:00Z"
  }
]
EOF

cat > "$PROJECT_NAME/src/pages/Documents.jsx" << 'EOF'
import useDocuments from '../hooks/useDocuments'

export default function Documents() {
  const { documents, loading, error } = useDocuments()

  if (loading) return <div className="p-8">Loading...</div>
  if (error) return <div className="p-8 text-red-500">Error: {error.message}</div>

  return (
    <div className="min-h-screen bg-gray-50 p-8">
      <h1 className="text-3xl font-bold text-gray-900 mb-6">Documents</h1>
      <div className="space-y-4">
        {documents.map(doc => (
          <div key={doc.id} className="bg-white rounded-lg shadow p-4">
            <h2 className="text-xl font-semibold">{doc.title}</h2>
            <p className="text-gray-600 mt-1">{doc.content}</p>
          </div>
        ))}
      </div>
    </div>
  )
}
EOF

cat > "$PROJECT_NAME/.env.example" << 'EOF'
VITE_API_URL=http://localhost:8000
VITE_USE_MOCK=true
EOF

cp "$PROJECT_NAME/.env.example" "$PROJECT_NAME/.env"

cat > "$PROJECT_NAME/README.md" << EOF
# $PROJECT_NAME

React + Vite + Tailwind CSS

## Run

\`\`\`bash
npm install
npm run dev
\`\`\`

Opens at http://localhost:5173

## Environment

- \`VITE_API_URL\` — Backend URL (default: http://localhost:8000)
- \`VITE_USE_MOCK\` — Use mock data (default: true)

## Build

\`\`\`bash
npm run build
\`\`\`

Output in \`dist/\`.
EOF

echo "Done! cd $PROJECT_NAME && npm install && npm run dev"
