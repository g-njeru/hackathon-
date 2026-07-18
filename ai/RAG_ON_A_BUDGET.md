# RAG on a Budget

Build a RAG (Retrieval Augmented Generation) system without breaking the bank.

---

## What is RAG?

RAG combines **retrieval** (finding relevant documents) with **generation** (LLM producing answers). Instead of fine-tuning a model, you:

1. Store your documents as embeddings in a vector database
2. When a user asks a question, find the most relevant documents
3. Feed those documents to an LLM as context
4. The LLM generates an answer based on your documents

**Advantages over fine-tuning**: cheaper, faster, no GPU needed, easy to update knowledge.

---

## Free/Cheap RAG Options

### Option 1: pgvector (Recommended — you already have PostgreSQL)

**Cost**: Free (you already pay for PG)
**Setup time**: 10 minutes

```bash
# Enable pgvector extension
CREATE EXTENSION vector;
```

```python
from pgvector.sqlalchemy import Vector
from sqlalchemy import Column, Text, String

class Document(Base):
    __tablename__ = "documents"

    id = Column(String, primary_key=True)
    content = Column(Text)
    embedding = Column(Vector(384))  # 384 dimensions for all-MiniLM-L6-v2
```

```python
# Search for similar documents
from sqlalchemy import text

query_embedding = get_embedding("What is hackathon?")

results = db.execute(
    text("""
        SELECT content, 1 - (embedding <=> :embedding) as similarity
        FROM documents
        ORDER BY embedding <=> :embedding
        LIMIT 5
    """),
    {"embedding": str(query_embedding)}
)
```

**Pros**: No new infrastructure, SQL queries, ACID transactions
**Cons**: Limited vector operations compared to dedicated vector DBs

---

### Option 2: ChromaDB (Local, Zero Cost)

**Cost**: Free (runs locally)
**Setup time**: 5 minutes

```bash
pip install chromadb sentence-transformers
```

```python
import chromadb
from sentence_transformers import SentenceTransformer

# Initialize
model = SentenceTransformer('all-MiniLM-L6-v2')
client = chromadb.Client()
collection = client.create_collection("documents")

# Add documents
documents = ["Document 1 text", "Document 2 text"]
embeddings = model.encode(documents).tolist()

collection.add(
    documents=documents,
    embeddings=embeddings,
    ids=["doc1", "doc2"]
)

# Query
query = "What is hackathon?"
query_embedding = model.encode([query]).tolist()

results = collection.query(
    query_embeddings=query_embedding,
    n_results=5
)
```

**Pros**: Zero infrastructure, fast, easy to use
**Cons**: Data stored in memory/disk, not distributed

---

### Option 3: HuggingFace Inference API (Free Tier)

**Cost**: Free (rate-limited)
**Setup time**: 5 minutes

```python
import requests

API_URL = "https://api-inference.huggingface.co/models/sentence-transformers/all-MiniLM-L6-v2"
headers = {"Authorization": "Bearer hf_your_token"}

def get_embedding(text):
    response = requests.post(API_URL, headers=headers, json={"inputs": text})
    return response.json()
```

**Pros**: No local compute needed, easy API
**Cons**: Rate limits, network dependency, latency

---

### Option 4: Ollama (Local LLM + Embeddings)

**Cost**: Free (runs locally, needs GPU for speed)
**Setup time**: 15 minutes

```bash
# Install Ollama
curl -fsSL https://ollama.ai/install.sh | sh

# Pull a model
ollama pull nomic-embed-text  # Embeddings
ollama pull llama3            # LLM for generation
```

```python
import ollama

# Get embeddings
response = ollama.embeddings(model="nomic-embed-text", prompt="What is hackathon?")
embedding = response["embedding"]

# Generate answer
response = ollama.chat(
    model="llama3",
    messages=[{
        "role": "system",
        "content": "Answer based on the provided context."
    }, {
        "role": "user",
        "content": f"Context: {context}\n\nQuestion: What is hackathon?"
    }]
)
```

**Pros**: Fully local, no API costs, no rate limits
**Cons**: Needs decent hardware, slower without GPU

---

## Comparison

| Option | Cost | Setup | Quality | Best for |
|---|---|---|---|---|
| **pgvector** | Free (existing PG) | 10 min | Good | Hackathons with existing PG |
| **ChromaDB** | Free | 5 min | Good | Quick prototypes, local dev |
| **HuggingFace API** | Free tier | 5 min | Good | No local compute |
| **Ollama** | Free | 15 min | Best | Offline, full control |

---

## RAG Pipeline (FastAPI)

### Basic implementation

```python
from fastapi import FastAPI, Depends
from pydantic import BaseModel
from sentence_transformers import SentenceTransformer
import chromadb

app = FastAPI()
model = SentenceTransformer('all-MiniLM-L6-v2')
client = chromadb.Client()
collection = client.create_collection("documents")

class QueryRequest(BaseModel):
    question: str

class QueryResponse(BaseModel):
    answer: str
    sources: list[str]

@app.post("/rag/query", response_model=QueryResponse)
async def rag_query(req: QueryRequest):
    # 1. Get query embedding
    query_embedding = model.encode([req.question]).tolist()

    # 2. Retrieve relevant documents
    results = collection.query(
        query_embeddings=query_embedding,
        n_results=3
    )

    context = "\n\n".join(results["documents"][0])

    # 3. Generate answer (using Ollama or any LLM)
    import ollama
    response = ollama.chat(
        model="llama3",
        messages=[{
            "role": "system",
            "content": f"Answer based on this context:\n{context}"
        }, {
            "role": "user",
            "content": req.question
        }]
    )

    return QueryResponse(
        answer=response["message"]["content"],
        sources=results["documents"][0]
    )
```

---

## Adding Documents

```python
@app.post("/rag/documents")
async def add_documents(documents: list[str]):
    embeddings = model.encode(documents).tolist()
    ids = [f"doc-{i}" for i in range(len(documents))]

    collection.add(
        documents=documents,
        embeddings=embeddings,
        ids=ids
    )

    return {"added": len(documents)}
```

---

## Hackathon RAG Checklist

1. [ ] Choose vector storage (pgvector or ChromaDB)
2. [ ] Set up embedding model (sentence-transformers)
3. [ ] Create document ingestion endpoint
4. [ ] Create query endpoint
5. [ ] Test with sample documents
6. [ ] Connect to LLM for generation (Ollama or API)
7. [ ] Build simple UI for querying
8. [ ] Deploy and share
