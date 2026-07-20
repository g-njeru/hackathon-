# Frontend Auth Patterns — React + Vite

Auth context, protected routes, and token management for JWT backends.

## Architecture

```
Login/Signup → AuthContext (stores token + user) → ProtectedRoute → API calls with token
```

## Auth Context — full implementation

```jsx
// src/context/AuthContext.jsx
import { createContext, useContext, useState, useEffect } from 'react'

const AuthContext = createContext(null)
const API_URL = import.meta.env.VITE_API_URL || ''

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null)
  const [token, setToken] = useState(localStorage.getItem('token'))
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    if (token) {
      fetch(`${API_URL}/api/auth/me`, {
        headers: { Authorization: `Bearer ${token}` }
      })
        .then(r => { if (!r.ok) throw new Error(); return r.json() })
        .then(setUser)
        .catch(() => { localStorage.removeItem('token'); setToken(null) })
        .finally(() => setLoading(false))
    } else {
      setLoading(false)
    }
  }, [token])

  const login = async (email, password) => {
    const res = await fetch(`${API_URL}/api/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password })
    })
    if (!res.ok) {
      const err = await res.json()
      throw new Error(err.detail || 'Login failed')
    }
    const data = await res.json()
    localStorage.setItem('token', data.token)
    setToken(data.token)
    setUser({ id: data.id, email: data.email })
  }

  const signup = async (email, password) => {
    const res = await fetch(`${API_URL}/api/auth/signup`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password })
    })
    if (!res.ok) {
      const err = await res.json()
      throw new Error(err.detail || 'Signup failed')
    }
    const data = await res.json()
    localStorage.setItem('token', data.token)
    setToken(data.token)
    setUser({ id: data.id, email: data.email })
  }

  const logout = () => {
    localStorage.removeItem('token')
    setToken(null)
    setUser(null)
  }

  return (
    <AuthContext.Provider value={{ user, token, loading, login, signup, logout }}>
      {children}
    </AuthContext.Provider>
  )
}

export const useAuth = () => useContext(AuthContext)
```

## Protected Route

```jsx
// src/components/ProtectedRoute.jsx
import { Navigate } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'

export default function ProtectedRoute({ children }) {
  const { user, loading } = useAuth()
  if (loading) return <div className="p-8">Loading...</div>
  if (!user) return <Navigate to="/login" />
  return children
}
```

## Routing with auth

```jsx
// src/App.jsx
import { BrowserRouter, Routes, Route } from 'react-router-dom'
import { AuthProvider } from './context/AuthContext'
import ProtectedRoute from './components/ProtectedRoute'
import Login from './pages/Login'
import Signup from './pages/Signup'
import Documents from './pages/Documents'

export default function App() {
  return (
    <BrowserRouter>
      <AuthProvider>
        <Routes>
          <Route path="/login" element={<Login />} />
          <Route path="/signup" element={<Signup />} />
          <Route path="/" element={
            <ProtectedRoute><Documents /></ProtectedRoute>
          } />
        </Routes>
      </AuthProvider>
    </BrowserRouter>
  )
}
```

## Attach token to API calls

```javascript
// src/api/documents.js
function authHeaders() {
  const token = localStorage.getItem('token')
  return token ? { Authorization: `Bearer ${token}` } : {}
}

export async function fetchDocuments() {
  const res = await fetch('/api/documents', { headers: authHeaders() })
  if (!res.ok) throw new Error('Failed to fetch')
  return res.json()
}

export async function createDocument(data) {
  const res = await fetch('/api/documents', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', ...authHeaders() },
    body: JSON.stringify(data)
  })
  if (!res.ok) throw new Error('Failed to create')
  return res.json()
}
```

## Login page pattern

```jsx
import { useState } from 'react'
import { useAuth } from '../context/AuthContext'

export default function Login() {
  const { login } = useAuth()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')

  const handleSubmit = async (e) => {
    e.preventDefault()
    setError('')
    try {
      await login(email, password)
      // navigation handled by App.jsx route changes
    } catch (err) {
      setError(err.message)
    }
  }

  return (
    <form onSubmit={handleSubmit}>
      {error && <div className="text-red-600">{error}</div>}
      <input type="email" value={email} onChange={e => setEmail(e.target.value)} required />
      <input type="password" value={password} onChange={e => setPassword(e.target.value)} required />
      <button type="submit">Log in</button>
    </form>
  )
}
```

## Mock mode for fast dev

```javascript
const USE_MOCK = import.meta.env.VITE_USE_MOCK === 'true'

// In AuthContext — mock login skips API
const login = async (email, password) => {
  if (USE_MOCK) {
    setToken('mock-token')
    setUser({ id: 'mock-user-1', email })
    return
  }
  // ... real API call
}
```

## Key decisions

| Decision | Choice | Why |
|----------|--------|-----|
| Token storage | localStorage | Simple, works for MVP |
| Auth state | React Context | No extra deps, sufficient for MVP |
| Token format | Bearer header | Standard, works with FastAPI HTTPBearer |
| Mock support | env var toggle | Dev without backend, same component tree |

## Common pitfalls

| Pitfall | Fix |
|---------|-----|
| Token sent as query param | Use Authorization header |
| No loading state on mount | Check token validity before rendering |
| Error not shown to user | Store error in state, display in UI |
| Navigation after login | Use React Router, not window.location |
| Mock mode forgets token | Store mock token in localStorage too |
