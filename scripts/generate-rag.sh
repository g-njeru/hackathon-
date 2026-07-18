#!/bin/bash
set -e

PROJECT_NAME="${1:-my-rag}"

echo "Generating $PROJECT_NAME..."

mkdir -p "$PROJECT_NAME/app/routes"

cat > "$PROJECT_NAME/app/__init__.py" << 'EOF'
EOF

cat > "$PROJECT_NAME/app/main.py" << 'EOF'
from fastapi import FastAPI, Depends
from pydantic import BaseModel
from app.embeddings import get_embedding, embed_documents
from app.database import get_db, init_db
from app.models import Document
from sqlalchemy import text

app = FastAPI(title="RAG API", version="0.1.0")

@app.on_event("startup")
async def startup():
    await init_db()

class IngestRequest(BaseModel):
    documents: list[str]

class QueryRequest(BaseModel):
    question: str
    top_k: int = 3

class QueryResponse(BaseModel):
    answer: str
    sources: list[str]

@app.get("/health")
async def health():
    return {"status": "ok"}

@app.post("/documents")
async def ingest_documents(req: IngestRequest, db=Depends(get_db)):
    embeddings = embed_documents(req.documents)
    for doc_text, embedding in zip(req.documents, embeddings):
        db_doc = Document(content=doc_text, embedding=str(embedding))
        db.add(db_doc)
    await db.commit()
    return {"added": len(req.documents)}

@app.post("/query", response_model=QueryResponse)
async def query_documents(req: QueryRequest, db=Depends(get_db)):
    query_embedding = get_embedding(req.question)

    result = await db.execute(
        text("""
            SELECT content, 1 - (embedding <=> :embedding) as similarity
            FROM documents
            ORDER BY embedding <=> :embedding
            LIMIT :limit
        """),
        {"embedding": str(query_embedding), "limit": req.top_k}
    )
    rows = result.fetchall()

    context = "\n\n".join([row[0] for row in rows])
    sources = [row[0][:100] for row in rows]

    return QueryResponse(
        answer=f"Based on {len(rows)} relevant documents: {context[:200]}...",
        sources=sources
    )

@app.get("/documents")
async def list_documents(db=Depends(get_db)):
    result = await db.execute(text("SELECT id, content FROM documents LIMIT 10"))
    return [{"id": row[0], "content": row[1][:100]} for row in result.fetchall()]
EOF

cat > "$PROJECT_NAME/app/embeddings.py" << 'EOF'
from sentence_transformers import SentenceTransformer

_model = None

def _get_model():
    global _model
    if _model is None:
        _model = SentenceTransformer("all-MiniLM-L6-v2")
    return _model

def get_embedding(text: str) -> list[float]:
    model = _get_model()
    return model.encode(text).tolist()

def embed_documents(texts: list[str]) -> list[list[float]]:
    model = _get_model()
    return model.encode(texts).tolist()
EOF

cat > "$PROJECT_NAME/app/database.py" << 'EOF'
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from sqlalchemy import text
from app.models import Base

DATABASE_URL = "postgresql+asyncpg://postgres:password@localhost:5432/rag"

engine = create_async_engine(DATABASE_URL)
async_session = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

async def init_db():
    async with engine.begin() as conn:
        await conn.execute(text("CREATE EXTENSION IF NOT EXISTS vector"))
        await conn.run_sync(Base.metadata.create_all)

async def get_db():
    async with async_session() as session:
        yield session
EOF

cat > "$PROJECT_NAME/app/models.py" << 'EOF'
from sqlalchemy import Column, String, Text
from app.database import engine
from sqlalchemy.orm import DeclarativeBase

class Base(DeclarativeBase):
    pass

class Document(Base):
    __tablename__ = "documents"

    id = Column(String, primary_key=True, default=lambda: __import__("uuid").uuid4().hex)
    content = Column(Text, nullable=False)
    embedding = Column(String, nullable=False)
EOF

cat > "$PROJECT_NAME/app/schemas.py" << 'EOF'
from pydantic import BaseModel

class IngestRequest(BaseModel):
    documents: list[str]

class QueryRequest(BaseModel):
    question: str
    top_k: int = 3
EOF

cat > "$PROJECT_NAME/requirements.txt" << 'EOF'
fastapi==0.115.0
uvicorn[standard]==0.30.0
sqlalchemy[asyncio]==2.0.35
asyncpg==0.29.0
sentence-transformers==3.1.0
pgvector==0.3.0
EOF

cat > "$PROJECT_NAME/Dockerfile" << 'EOF'
FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y build-essential && rm -rf /var/lib/apt/lists/*

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
    depends_on:
      - db

  db:
    image: pgvector/pgvector:pg16
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
      POSTGRES_DB: rag
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data

volumes:
  pgdata:
EOF

cat > "$PROJECT_NAME/.env.example" << 'EOF'
DATABASE_URL=postgresql+asyncpg://postgres:password@localhost:5432/rag
EOF

cat > "$PROJECT_NAME/README.md" << EOF
# $PROJECT_NAME

RAG pipeline with FastAPI + pgvector + sentence-transformers

## Run

\`\`\`bash
docker-compose up
\`\`\`

## Usage

### Ingest documents

\`\`\`bash
curl -X POST http://localhost:8000/documents \\
  -H "Content-Type: application/json" \\
  -d '{"documents": ["Document 1 text", "Document 2 text"]}'
\`\`\`

### Query

\`\`\`bash
curl -X POST http://localhost:8000/query \\
  -H "Content-Type: application/json" \\
  -d '{"question": "What is this about?"}'
\`\`\`

### List documents

\`\`\`bash
curl http://localhost:8000/documents
\`\`\`

## API Docs

http://localhost:8000/docs

## Stop

\`\`\`bash
docker-compose down -v
\`\`\`
EOF

echo "Done! cd $PROJECT_NAME && docker-compose up"
