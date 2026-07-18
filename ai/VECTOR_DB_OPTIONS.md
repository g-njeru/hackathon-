# Vector Database Options

Compare vector databases for RAG and similarity search.

---

## Quick Comparison

| Database | Type | Cost | Best for |
|---|---|---|---|
| **pgvector** | PostgreSQL extension | Free (existing PG) | Hackathons, existing PG users |
| **ChromaDB** | Embedded | Free | Quick prototypes, local dev |
| **Qdrant** | Standalone server | Free (self-hosted) | Production-ready, Rust performance |
| **Weaviate** | Standalone server | Free (self-hosted) | GraphQL API, modules |
| **Pinecone** | Managed | Free tier | Zero ops, managed service |
| **Milvus** | Standalone server | Free (self-hosted) | Large-scale, GPU acceleration |

---

## pgvector

**Type**: PostgreSQL extension
**Cost**: Free (you already have PG)
**Setup**: `CREATE EXTENSION vector;`

### Pros
- No new infrastructure — use your existing PostgreSQL
- SQL queries, ACID transactions, joins
- Good enough for most hackathon use cases
- Managed providers (Supabase, Neon) support it

### Cons
- Limited vector operations vs dedicated DBs
- Slower for >1M vectors
- No native vector-specific optimizations

### When to use
- You already have PostgreSQL
- You want to avoid adding infrastructure
- Your dataset is <100K vectors

### Setup

```sql
CREATE EXTENSION vector;

CREATE TABLE documents (
    id TEXT PRIMARY KEY,
    content TEXT,
    embedding VECTOR(384)
);

CREATE INDEX ON documents USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);
```

---

## ChromaDB

**Type**: Embedded (in-process) or client-server
**Cost**: Free
**Setup**: `pip install chromadb`

### Pros
- Zero infrastructure — runs in your Python process
- Simple API, easy to learn
- Built-in embedding support
- Persistent or in-memory modes

### Cons
- Single-node only (no distributed)
- Not suitable for production at scale
- Limited querying capabilities

### When to use
- Quick prototypes
- Local development
- Hackathons

### Setup

```python
import chromadb

# In-memory
client = chromadb.Client()

# Persistent
client = chromadb.PersistentClient(path="./chroma_db")

collection = client.create_collection("documents")
collection.add(
    documents=["doc1", "doc2"],
    ids=["id1", "id2"]
)
results = collection.query(query_texts=["search term"], n_results=5)
```

---

## Qdrant

**Type**: Standalone server
**Cost**: Free (self-hosted), paid cloud
**Setup**: Docker or binary

### Pros
- Written in Rust — very fast
- Rich filtering capabilities
- REST and gRPC APIs
- Horizontal scaling

### Cons
- Requires running a separate service
- More complex setup than ChromaDB

### When to use
- Production applications
- Need advanced filtering
- High-throughput requirements

### Setup

```bash
docker run -p 6333:6333 qdrant/qdrant
```

```python
from qdrant_client import QdrantClient
from qdrant_client.models import VectorParams, Distance, PointStruct

client = QdrantClient("localhost", port=6333)

client.create_collection(
    collection_name="documents",
    vectors_config=VectorParams(size=384, distance=Distance.COSINE)
)

client.upsert(
    collection_name="documents",
    points=[
        PointStruct(id=1, vector=[0.1]*384, payload={"content": "doc1"}),
        PointStruct(id=2, vector=[0.2]*384, payload={"content": "doc2"}),
    ]
)

results = client.search(
    collection_name="documents",
    query_vector=[0.1]*384,
    limit=5
)
```

---

## Weaviate

**Type**: Standalone server
**Cost**: Free (self-hosted), paid cloud
**Setup**: Docker or binary

### Pros
- GraphQL API
- Built-in vectorization modules
- Hybrid search (vector + keyword)
- Good documentation

### Cons
- More complex than necessary for simple use cases
- Resource-heavy

### When to use
- Need built-in vectorization
- Want GraphQL interface
- Hybrid search requirements

### Setup

```bash
docker run -p 8080:8080 -p 50051:50051 semitechnologies/weaviate
```

---

## Pinecone

**Type**: Managed cloud service
**Cost**: Free tier (100K vectors, 1GB)
**Setup**: API key

### Pros
- Zero infrastructure management
- Always up-to-date
- Easy to start

### Cons
- Vendor lock-in
- Paid tiers can get expensive
- Less control

### When to use
- No infrastructure management desired
- Small datasets (free tier)
- Quick prototyping

---

## Recommendation by Scenario

| Scenario | Recommendation |
|---|---|
| **Hackathon (existing PG)** | pgvector — no new infra |
| **Hackathon (quick prototype)** | ChromaDB — zero setup |
| **Production app** | Qdrant or managed Pinecone |
| **Need GraphQL** | Weaviate |
| **Large scale (>1M vectors)** | Qdrant, Milvus, or Weaviate |

---

## Embedding Models

| Model | Dimensions | Speed | Quality |
|---|---|---|---|
| `all-MiniLM-L6-v2` | 384 | Fast | Good |
| `all-mpnet-base-v2` | 768 | Medium | Better |
| `text-embedding-3-small` (OpenAI) | 1536 | Fast | Best |
| `nomic-embed-text` (Ollama) | 768 | Medium | Good |

**For hackathons**: Use `all-MiniLM-L6-v2` — fast, good quality, runs locally.
