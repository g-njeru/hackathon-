#!/bin/bash
set -e

PROJECT_NAME="${1:-my-backend}"

echo "Generating $PROJECT_NAME..."

mkdir -p "$PROJECT_NAME/app/routes"

cat > "$PROJECT_NAME/app/__init__.py" << 'EOF'
EOF

cat > "$PROJECT_NAME/app/main.py" << 'EOF'
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.config import settings
from app.routes import documents

app = FastAPI(title="Hackathon API", version="0.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(documents.router, prefix="/api")

@app.get("/health")
async def health():
    return {"status": "ok", "version": "0.1.0"}

@app.get("/health/ready")
async def ready():
    return {"status": "ready"}
EOF

cat > "$PROJECT_NAME/app/config.py" << 'EOF'
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    database_url: str = "postgresql+asyncpg://postgres:password@localhost:5432/hackathon"
    redis_url: str = "redis://localhost:6379"
    debug: bool = False

    class Config:
        env_file = ".env"

settings = Settings()
EOF

cat > "$PROJECT_NAME/app/database.py" << 'EOF'
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from sqlalchemy.orm import DeclarativeBase
from app.config import settings

engine = create_async_engine(settings.database_url)
async_session = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

class Base(DeclarativeBase):
    pass

async def get_db():
    async with async_session() as session:
        yield session
EOF

cat > "$PROJECT_NAME/app/models.py" << 'EOF'
from sqlalchemy import Column, String, Text, DateTime
from sqlalchemy.sql import func
from app.database import Base

class Document(Base):
    __tablename__ = "documents"

    id = Column(String, primary_key=True, default=lambda: __import__("uuid").uuid4().hex)
    title = Column(String, nullable=False)
    content = Column(Text, default="")
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
EOF

cat > "$PROJECT_NAME/app/schemas.py" << 'EOF'
from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class DocumentCreate(BaseModel):
    title: str
    content: str = ""

class DocumentUpdate(BaseModel):
    title: Optional[str] = None
    content: Optional[str] = None

class DocumentResponse(BaseModel):
    id: str
    title: str
    content: str
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
EOF

cat > "$PROJECT_NAME/app/routes/__init__.py" << 'EOF'
EOF

cat > "$PROJECT_NAME/app/routes/documents.py" << 'EOF'
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.database import get_db
from app.models import Document
from app.schemas import DocumentCreate, DocumentUpdate, DocumentResponse

router = APIRouter(tags=["documents"])

@router.get("/documents", response_model=list[DocumentResponse])
async def list_documents(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Document).order_by(Document.created_at.desc()))
    return result.scalars().all()

@router.post("/documents", response_model=DocumentResponse, status_code=201)
async def create_document(doc: DocumentCreate, db: AsyncSession = Depends(get_db)):
    db_doc = Document(**doc.model_dump())
    db.add(db_doc)
    await db.commit()
    await db.refresh(db_doc)
    return db_doc

@router.get("/documents/{doc_id}", response_model=DocumentResponse)
async def get_document(doc_id: str, db: AsyncSession = Depends(get_db)):
    doc = await db.get(Document, doc_id)
    if not doc:
        raise HTTPException(status_code=404, detail="Not found")
    return doc

@router.patch("/documents/{doc_id}", response_model=DocumentResponse)
async def update_document(doc_id: str, update: DocumentUpdate, db: AsyncSession = Depends(get_db)):
    doc = await db.get(Document, doc_id)
    if not doc:
        raise HTTPException(status_code=404, detail="Not found")
    for field, value in update.model_dump(exclude_unset=True).items():
        setattr(doc, field, value)
    await db.commit()
    await db.refresh(doc)
    return doc

@router.delete("/documents/{doc_id}", status_code=204)
async def delete_document(doc_id: str, db: AsyncSession = Depends(get_db)):
    doc = await db.get(Document, doc_id)
    if not doc:
        raise HTTPException(status_code=404, detail="Not found")
    await db.delete(doc)
    await db.commit()
EOF

cat > "$PROJECT_NAME/requirements.txt" << 'EOF'
fastapi==0.115.0
uvicorn[standard]==0.30.0
pydantic==2.9.0
pydantic-settings==2.5.0
sqlalchemy[asyncio]==2.0.35
asyncpg==0.29.0
python-dotenv==1.0.1
EOF

cat > "$PROJECT_NAME/Dockerfile" << 'EOF'
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
EOF

cat > "$PROJECT_NAME/docker-compose.yml" << 'EOF'
services:
  app:
    build: .
    ports:
      - "8000:8000"
    env_file: .env
    depends_on:
      - db
      - redis

  db:
    image: postgres:16
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
      POSTGRES_DB: hackathon
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

volumes:
  pgdata:
EOF

cat > "$PROJECT_NAME/.env.example" << 'EOF'
DATABASE_URL=postgresql+asyncpg://postgres:password@localhost:5432/hackathon
REDIS_URL=redis://localhost:6379
DEBUG=true
EOF

cp "$PROJECT_NAME/.env.example" "$PROJECT_NAME/.env"

cat > "$PROJECT_NAME/README.md" << EOF
# $PROJECT_NAME

FastAPI + PostgreSQL + Redis

## Run

\`\`\`bash
docker-compose up
\`\`\`

## API

- Docs: http://localhost:8000/docs
- Health: http://localhost:8000/health
- Documents: http://localhost:8000/api/documents

## Stop

\`\`\`bash
docker-compose down -v
\`\`\`
EOF

echo "Done! cd $PROJECT_NAME && docker-compose up"
