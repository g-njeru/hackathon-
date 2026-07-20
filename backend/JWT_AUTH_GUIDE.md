# JWT Authentication — FastAPI + React

Self-contained auth with no external services. Works offline, free forever.

## Backend Setup

### Install dependencies

```bash
pip install pyjwt passlib[bcrypt] bcrypt email-validator
```

### Config — add JWT secret

```python
# app/config.py
class Settings(BaseSettings):
    jwt_secret: str = "change-me-in-production"
```

### Auth module — core logic

```python
# app/auth.py
from datetime import datetime, timedelta
import jwt
from passlib.context import CryptContext
from fastapi import Depends, HTTPException
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
security = HTTPBearer()
ALGORITHM = "HS256"
TOKEN_EXPIRE_MINUTES = 60 * 24  # 24h

def hash_password(password: str) -> str:
    return pwd_context.hash(password)

def verify_password(plain: str, hashed: str) -> bool:
    return pwd_context.verify(plain, hashed)

def create_token(data: dict) -> str:
    to_encode = data.copy()
    to_encode["exp"] = datetime.utcnow() + timedelta(minutes=TOKEN_EXPIRE_MINUTES)
    return jwt.encode(to_encode, settings.jwt_secret, algorithm=ALGORITHM)

def decode_token(token: str) -> dict:
    try:
        return jwt.decode(token, settings.jwt_secret, algorithms=[ALGORITHM])
    except jwt.ExpiredSignatureError:
        raise HTTPException(401, "Token expired")
    except jwt.InvalidTokenError:
        raise HTTPException(401, "Invalid token")

async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: AsyncSession = Depends(get_db),
):
    payload = decode_token(credentials.credentials)
    user_id = payload.get("sub")
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(401, "User not found")
    return user
```

### User model

```python
# app/models.py
class User(Base):
    __tablename__ = "users"
    id = Column(String, primary_key=True, default=lambda: uuid4().hex)
    email = Column(String, unique=True, nullable=False, index=True)
    hashed_password = Column(String, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
```

### Auth routes

```python
# app/routes/auth.py
router = APIRouter(prefix="/auth", tags=["auth"])

@router.post("/signup", response_model=AuthResponse, status_code=201)
async def signup(req: SignupRequest, db: AsyncSession = Depends(get_db)):
    existing = await db.execute(select(User).where(User.email == req.email))
    if existing.scalar_one_or_none():
        raise HTTPException(400, "Email already registered")
    user = User(email=req.email, hashed_password=hash_password(req.password))
    db.add(user)
    await db.commit()
    token = create_token({"sub": user.id})
    return AuthResponse(token=token, email=user.email, id=user.id)

@router.post("/login", response_model=AuthResponse)
async def login(req: LoginRequest, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.email == req.email))
    user = result.scalar_one_or_none()
    if not user or not verify_password(req.password, user.hashed_password):
        raise HTTPException(401, "Invalid email or password")
    token = create_token({"sub": user.id})
    return AuthResponse(token=token, email=user.email, id=user.id)

@router.get("/me", response_model=UserResponse)
async def me(user: User = Depends(get_current_user)):
    return user
```

### Register router + protect routes

```python
# app/main.py
app.include_router(auth.router, prefix="/api")

# Protected route — add user param
@router.get("/documents")
async def list_documents(
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Document).where(Document.user_id == user.id)
    )
    return result.scalars().all()
```

## Frontend (React + Vite)

### Auth context

```jsx
// src/context/AuthContext.jsx
import { createContext, useContext, useState, useEffect } from 'react'

const AuthContext = createContext(null)

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null)
  const [token, setToken] = useState(localStorage.getItem('token'))

  useEffect(() => {
    if (token) {
      fetch('/api/auth/me', {
        headers: { Authorization: `Bearer ${token}` }
      })
        .then(r => r.json())
        .then(setUser)
        .catch(() => { localStorage.removeItem('token'); setToken(null) })
    }
  }, [token])

  const login = async (email, password) => {
    const res = await fetch('/api/auth/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password })
    })
    const data = await res.json()
    localStorage.setItem('token', data.token)
    setToken(data.token)
    setUser({ id: data.id, email: data.email })
  }

  const signup = async (email, password) => {
    const res = await fetch('/api/auth/signup', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password })
    })
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
    <AuthContext.Provider value={{ user, token, login, signup, logout }}>
      {children}
    </AuthContext.Provider>
  )
}

export const useAuth = () => useContext(AuthContext)
```

### Protected route wrapper

```jsx
// src/components/ProtectedRoute.jsx
import { Navigate } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'

export function ProtectedRoute({ children }) {
  const { user } = useAuth()
  if (!user) return <Navigate to="/login" />
  return children
}
```

### Attach token to API calls

```javascript
// src/api/documents.js
const token = localStorage.getItem('token')

export async function fetchDocuments() {
  const res = await fetch('/api/documents', {
    headers: { Authorization: `Bearer ${token}` }
  })
  return res.json()
}
```

## Token Flow

```
1. User logs in → POST /api/auth/login
2. Server returns { token, email, id }
3. Client stores token in localStorage
4. Client sends Authorization: Bearer <token> on every request
5. Server decodes token → gets user_id → filters data by user
```

## Common Pitfalls

| Pitfall | Fix |
|---------|-----|
| Secret hardcoded in source | Use env vars, rotate regularly |
| No token expiry | Set reasonable expiry (24h), implement refresh later |
| Store token in localStorage | Acceptable for MVP; for production use httpOnly cookies |
| Expose error details | Return generic "Invalid credentials" on login failure |
| Forget to add user_id to documents | Always include user_id in protected queries |

## Security Checklist

- [ ] JWT_SECRET from environment variable (not hardcoded)
- [ ] Passwords hashed with bcrypt (never stored plain)
- [ ] Token expiry set (24h recommended for MVP)
- [ ] User ID extracted from token, not client input
- [ ] All queries filtered by user_id
- [ ] Generic error messages on auth failure
