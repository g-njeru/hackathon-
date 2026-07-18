# FastAPI Quickstart

Scaffold and run a FastAPI project in minutes.

---

## Setup

### Install

```bash
pip install fastapi uvicorn[standard] pydantic python-dotenv
```

### Minimal app

```python
# main.py
from fastapi import FastAPI

app = FastAPI()

@app.get("/health")
async def health():
    return {"status": "ok"}
```

### Run

```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

- `--reload` — auto-restart on code changes
- API docs at `http://localhost:8000/docs`
- ReDoc at `http://localhost:8000/redoc`

---

## Project Structure

```
backend/
├── app/
│   ├── __init__.py
│   ├── main.py              # App entry point
│   ├── config.py            # Settings / env vars
│   ├── database.py          # DB connection
│   ├── models/              # SQLAlchemy models
│   │   └── document.py
│   ├── schemas/             # Pydantic schemas
│   │   └── document.py
│   └── routes/              # API endpoints
│       └── documents.py
├── requirements.txt
└── Dockerfile
```

---

## Routes & Endpoints

### Path parameters

```python
@app.get("/documents/{doc_id}")
async def get_document(doc_id: str):
    return {"id": doc_id}
```

### Query parameters

```python
from typing import Optional

@app.get("/documents")
async def list_documents(skip: int = 0, limit: int = 20, q: Optional[str] = None):
    return {"skip": skip, "limit": limit, "q": q}
```

### Request body

```python
from pydantic import BaseModel

class DocumentCreate(BaseModel):
    title: str
    content: str
    tags: list[str] = []

@app.post("/documents", status_code=201)
async def create_document(doc: DocumentCreate):
    return {"id": "new-id", **doc.model_dump()}
```

---

## Pydantic Schemas

```python
from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional

class DocumentBase(BaseModel):
    title: str = Field(..., min_length=1, max_length=200)
    content: str = ""
    tags: list[str] = []

class DocumentCreate(DocumentBase):
    pass

class DocumentUpdate(BaseModel):
    title: Optional[str] = None
    content: Optional[str] = None
    tags: Optional[list[str]] = None

class DocumentResponse(DocumentBase):
    id: str
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
```

---

## Database Connection (asyncpg + SQLAlchemy)

```python
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from sqlalchemy.orm import DeclarativeBase

DATABASE_URL = "postgresql+asyncpg://postgres:password@localhost:5432/hackathon"

engine = create_async_engine(DATABASE_URL)
async_session = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

class Base(DeclarativeBase):
    pass

async def get_db():
    async with async_session() as session:
        yield session
```

### Dependency injection

```python
from fastapi import Depends

@app.get("/documents")
async def list_documents(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Document))
    return result.scalars().all()
```

---

## Error Handling

```python
from fastapi import HTTPException

@app.get("/documents/{doc_id}")
async def get_document(doc_id: str, db: AsyncSession = Depends(get_db)):
    doc = await db.get(Document, doc_id)
    if not doc:
        raise HTTPException(status_code=404, detail="Document not found")
    return doc
```

### Custom exception handler

```python
from fastapi import Request
from fastapi.responses import JSONResponse

class AppError(Exception):
    def __init__(self, status_code: int, detail: str):
        self.status_code = status_code
        self.detail = detail

@app.exception_handler(AppError)
async def app_error_handler(request: Request, exc: AppError):
    return JSONResponse(status_code=exc.status_code, content={"detail": exc.detail})
```

---

## CORS

```python
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173"],  # Vite dev server
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

---

## Environment Variables

```python
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    database_url: str
    redis_url: str = "redis://localhost:6379"
    supabase_url: str = ""
    supabase_key: str = ""
    debug: bool = False

    class Config:
        env_file = ".env"

settings = Settings()
```

---

## Common Commands

```bash
# Run dev server
uvicorn app.main:app --reload

# Run tests
pytest

# Run tests with coverage
pytest --cov=app

# Lint
ruff check .
ruff format .

# Type check
mypy .
```

---

## Dockerfile

```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```
