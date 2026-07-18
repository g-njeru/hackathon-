# API Design Patterns

Copy-paste patterns for common API scenarios with FastAPI.

---

## Auth Patterns

### JWT Authentication

```python
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
import jwt
from datetime import datetime, timedelta

SECRET_KEY = "your-secret-key"
ALGORITHM = "HS256"

security = HTTPBearer()

def create_token(user_id: str, expires_minutes: int = 60) -> str:
    payload = {
        "sub": user_id,
        "exp": datetime.utcnow() + timedelta(minutes=expires_minutes)
    }
    return jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)

def decode_token(token: str) -> dict:
    try:
        return jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token expired")
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid token")

async def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security)):
    return decode_token(credentials.credentials)
```

### Use in routes

```python
@app.get("/protected")
async def protected_route(user=Depends(get_current_user)):
    return {"user_id": user["sub"]}
```

### Supabase Auth

```python
from supabase import create_client

supabase = create_client(SUPABASE_URL, SUPABASE_SERVICE_KEY)

async def get_current_user(authorization: str = Header(...)):
    token = authorization.replace("Bearer ", "")
    user = supabase.auth.get_user(token)
    if not user:
        raise HTTPException(status_code=401, detail="Invalid token")
    return user
```

### API Key Auth

```python
from fastapi import Security
from fastapi.security import APIKeyHeader

API_KEY = "your-api-key"
api_key_header = APIKeyHeader(name="X-API-Key")

async def verify_api_key(api_key: str = Security(api_key_header)):
    if api_key != API_KEY:
        raise HTTPException(status_code=403, detail="Invalid API key")
    return api_key

@app.get("/api/data")
async def get_data(api_key: str = Depends(verify_api_key)):
    return {"data": "secret"}
```

---

## CRUD Patterns

### Create

```python
@app.post("/documents", status_code=201, response_model=DocumentResponse)
async def create_document(
    doc: DocumentCreate,
    db: AsyncSession = Depends(get_db),
    user=Depends(get_current_user)
):
    db_doc = Document(**doc.model_dump(), user_id=user["sub"])
    db.add(db_doc)
    await db.commit()
    await db.refresh(db_doc)
    return db_doc
```

### Read (list)

```python
@app.get("/documents", response_model=list[DocumentResponse])
async def list_documents(
    skip: int = 0,
    limit: int = 20,
    db: AsyncSession = Depends(get_db),
    user=Depends(get_current_user)
):
    result = await db.execute(
        select(Document)
        .where(Document.user_id == user["sub"])
        .offset(skip)
        .limit(limit)
        .order_by(Document.created_at.desc())
    )
    return result.scalars().all()
```

### Read (single)

```python
@app.get("/documents/{doc_id}", response_model=DocumentResponse)
async def get_document(
    doc_id: str,
    db: AsyncSession = Depends(get_db),
    user=Depends(get_current_user)
):
    doc = await db.get(Document, doc_id)
    if not doc or doc.user_id != user["sub"]:
        raise HTTPException(status_code=404, detail="Not found")
    return doc
```

### Update

```python
@app.patch("/documents/{doc_id}", response_model=DocumentResponse)
async def update_document(
    doc_id: str,
    update: DocumentUpdate,
    db: AsyncSession = Depends(get_db),
    user=Depends(get_current_user)
):
    doc = await db.get(Document, doc_id)
    if not doc or doc.user_id != user["sub"]:
        raise HTTPException(status_code=404, detail="Not found")

    for field, value in update.model_dump(exclude_unset=True).items():
        setattr(doc, field, value)

    await db.commit()
    await db.refresh(doc)
    return doc
```

### Delete

```python
@app.delete("/documents/{doc_id}", status_code=204)
async def delete_document(
    doc_id: str,
    db: AsyncSession = Depends(get_db),
    user=Depends(get_current_user)
):
    doc = await db.get(Document, doc_id)
    if not doc or doc.user_id != user["sub"]:
        raise HTTPException(status_code=404, detail="Not found")
    await db.delete(doc)
    await db.commit()
```

---

## WebSocket Pattern

```python
from fastapi import WebSocket, WebSocketDisconnect

class ConnectionManager:
    def __init__(self):
        self.active: list[WebSocket] = []

    async def connect(self, ws: WebSocket):
        await ws.accept()
        self.active.append(ws)

    def disconnect(self, ws: WebSocket):
        self.active.remove(ws)

    async def broadcast(self, message: str):
        for conn in self.active:
            await conn.send_text(message)

manager = ConnectionManager()

@app.websocket("/ws")
async def websocket_endpoint(ws: WebSocket):
    await manager.connect(ws)
    try:
        while True:
            data = await ws.receive_text()
            await manager.broadcast(f"Message: {data}")
    except WebSocketDisconnect:
        manager.disconnect(ws)
```

---

## Response Patterns

### Paginated response

```python
from pydantic import BaseModel
from typing import Generic, TypeVar

T = TypeVar("T")

class PaginatedResponse(BaseModel, Generic[T]):
    items: list[T]
    total: int
    skip: int
    limit: int

@app.get("/documents", response_model=PaginatedResponse[DocumentResponse])
async def list_documents(skip: int = 0, limit: int = 20, db: AsyncSession = Depends(get_db)):
    total = await db.scalar(select(func.count(Document.id)))
    result = await db.execute(select(Document).offset(skip).limit(limit))
    return PaginatedResponse(
        items=result.scalars().all(),
        total=total,
        skip=skip,
        limit=limit
    )
```

### Error response

```python
from fastapi.responses import JSONResponse

class ErrorResponse(BaseModel):
    detail: str
    code: str

@app.exception_handler(HTTPException)
async def http_exception_handler(request, exc):
    return JSONResponse(
        status_code=exc.status_code,
        content={"detail": exc.detail, "code": "error"}
    )
```

---

## Health Check

```python
@app.get("/health")
async def health():
    return {"status": "ok", "version": "0.1.0"}

@app.get("/health/ready")
async def ready(db: AsyncSession = Depends(get_db)):
    try:
        await db.execute(text("SELECT 1"))
        return {"status": "ready", "database": "connected"}
    except Exception:
        raise HTTPException(status_code=503, detail="Database not ready")
```
