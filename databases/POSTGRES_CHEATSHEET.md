# PostgreSQL Cheatsheet

Quick reference for common PostgreSQL operations.

---

## Connection

```bash
# Connect to database
psql -U postgres -d hackathon

# Connect via URL
psql $DATABASE_URL

# List databases
\l

# List tables
\dt

# Describe table
\d table_name

# Quit
\q
```

---

## Schema Design

### Create table

```sql
CREATE TABLE documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    content TEXT,
    tags TEXT[] DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Common data types

| Type | Use for |
|---|---|
| `UUID` | Primary keys (no sequential leaks) |
| `TEXT` | Strings of any length |
| `INTEGER` / `BIGINT` | Whole numbers |
| `NUMERIC(precision, scale)` | Exact decimals (money) |
| `BOOLEAN` | True/false |
| `TIMESTAMPTZ` | Timestamps with timezone |
| `JSONB` | Structured JSON data |
| `TEXT[]` | Arrays of strings |

### Indexes

```sql
-- B-tree index (default, for equality/range)
CREATE INDEX idx_documents_title ON documents (title);

-- GIN index for full-text search
CREATE INDEX idx_documents_content_gin ON documents USING GIN (to_tsvector('english', content));

-- GIN index for JSONB
CREATE INDEX idx_documents_metadata ON documents USING GIN (metadata);

-- Partial index (index only subset of rows)
CREATE INDEX idx_documents_active ON documents (created_at) WHERE deleted_at IS NULL;
```

---

## Common Queries

### CRUD

```sql
-- Insert
INSERT INTO documents (title, content, tags)
VALUES ('Hello', 'World', ARRAY['test', 'demo'])
RETURNING id;

-- Select
SELECT id, title, content FROM documents WHERE tags @> ARRAY['demo'];

-- Update
UPDATE documents SET title = 'Updated' WHERE id = 'uuid-here';

-- Delete
DELETE FROM documents WHERE id = 'uuid-here';
```

### Filtering

```sql
-- Array contains
WHERE tags @> ARRAY['important']

-- JSONB contains
WHERE metadata @> '{"status": "active"}'

-- ILike (case-insensitive)
WHERE title ILIKE '%search%'

-- Full-text search
WHERE to_tsvector('english', content) @@ to_tsquery('english', 'search terms')

-- Range
WHERE created_at BETWEEN '2024-01-01' AND '2024-12-31'
```

### Aggregation

```sql
-- Count with group by
SELECT tags, COUNT(*) FROM documents GROUP BY tags;

-- Average, sum, min, max
SELECT AVG(score), SUM(score), MIN(score), MAX(score) FROM results;

-- Distinct
SELECT DISTINCT author FROM documents;
```

### Dashboard aggregation (real-world)

```sql
-- Total count for a user
SELECT COUNT(*) FROM documents WHERE user_id = $1;

-- Count with conditions
SELECT
  COUNT(*) AS total,
  COUNT(*) FILTER (WHERE content != '' AND content IS NOT NULL) AS with_content,
  COUNT(*) FILTER (WHERE content = '' OR content IS NULL) AS empty
FROM documents
WHERE user_id = $1;

-- Top 5 longest documents
SELECT id, title, LENGTH(content) AS content_length
FROM documents
WHERE user_id = $1
ORDER BY LENGTH(content) DESC
LIMIT 5;

-- Documents per day (last 7 days)
SELECT
  DATE(created_at) AS day,
  COUNT(*) AS count
FROM documents
WHERE user_id = $1
  AND created_at > NOW() - INTERVAL '7 days'
GROUP BY DATE(created_at)
ORDER BY day DESC;
```

### Pagination

```sql
-- Offset-based (simple, slow for large offsets)
SELECT * FROM documents ORDER BY created_at DESC LIMIT 20 OFFSET 40;

-- Cursor-based (fast, recommended)
SELECT * FROM documents
WHERE created_at < $last_cursor
ORDER BY created_at DESC
LIMIT 20;
```

---

## Migrations (Alembic)

```bash
# Initialize Alembic
alembic init alembic

# Generate migration
alembic revision --autogenerate -m "add documents table"

# Apply migrations
alembic upgrade head

# Rollback one step
alembic downgrade -1

# Rollback to specific revision
alembic downgrade <revision_id>
```

---

## Full-Text Search with pg_trgm

```sql
-- Enable extension
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Create index for trigram similarity
CREATE INDEX idx_documents_title_trgm ON documents USING GIN (title gin_trgm_ops);

-- Search with similarity
SELECT * FROM documents
WHERE title % 'search term'
ORDER BY similarity(title, 'search term') DESC;
```

---

## Performance Tips

1. **Use `EXPLAIN ANALYZE`** to see query plans
2. **Index columns** used in `WHERE`, `JOIN`, `ORDER BY`
3. **Avoid `SELECT *`** — only select what you need
4. **Use connection pooling** (PgBouncer) in production
5. **Batch inserts** instead of one-by-one
6. **Use `LIMIT`** to prevent unbounded result sets

---

## Docker Compose Quick Reference

```yaml
services:
  postgres:
    image: postgres:16
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
      POSTGRES_DB: hackathon
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data

volumes:
  pgdata:
```
