#!/bin/bash
set -e

PROJECT_NAME="${1:-my-observability}"

echo "Generating $PROJECT_NAME..."

mkdir -p "$PROJECT_NAME/app"

cat > "$PROJECT_NAME/docker-compose.yml" << 'EOF'
services:
  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana_data:/var/lib/grafana

  loki:
    image: grafana/loki:latest
    ports:
      - "3100:3100"
    volumes:
      - ./loki-config.yaml:/etc/loki/local-config.yaml

  app:
    build: ./app
    ports:
      - "8000:8000"
    depends_on:
      - loki

volumes:
  grafana_data:
EOF

cat > "$PROJECT_NAME/loki-config.yaml" << 'EOF'
auth_enabled: false

server:
  http_listen_port: 3100

common:
  path_prefix: /loki
  storage:
    filesystem:
      chunks_directory: /loki/chunks
      rules_directory: /loki/rules
  replication_factor: 1
  ring:
    kvstore:
      store: inmemory

schema_config:
  configs:
    - from: "2024-01-01"
      store: tsdb
      object_store: filesystem
      schema: v13
      index:
        prefix: index_
        period: 24h
EOF

cat > "$PROJECT_NAME/app/main.py" << 'EOF'
import logging
import requests
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="Observable App", version="0.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

LOKI_URL = "http://loki:3100"

logger = logging.getLogger("app")

@app.get("/health")
async def health():
    return {"status": "ok"}

@app.get("/documents")
async def list_documents():
    logger.info("listing documents")
    return {"documents": [{"id": "1", "title": "Sample"}]}

@app.post("/documents")
async def create_document(doc: dict):
    logger.info(f"creating document: {doc.get('title', 'unknown')}")
    return {"id": "2", **doc}

@app.exception_handler(Exception)
async def global_handler(request, exc):
    logger.error(f"error: {exc}")
    from fastapi.responses import JSONResponse
    return JSONResponse(status_code=500, content={"detail": "Internal error"})
EOF

cat > "$PROJECT_NAME/app/requirements.txt" << 'EOF'
fastapi==0.115.0
uvicorn[standard]==0.30.0
requests==2.32.0
EOF

cat > "$PROJECT_NAME/app/Dockerfile" << 'EOF'
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
EOF

cat > "$PROJECT_NAME/README.md" << EOF
# $PROJECT_NAME

Grafana + Loki + FastAPI sample app

## Run

\`\`\`bash
docker-compose up
\`\`\`

## Services

- Grafana: http://localhost:3000 (admin/admin)
- Loki: http://localhost:3100
- App: http://localhost:8000

## Setup Grafana

1. Open http://localhost:3000
2. Go to Settings > Data Sources > Add
3. Add Loki: \`http://loki:3100\`
4. Go to Explore, select Loki data source
5. Query: \`{app="app"}\`

## Stop

\`\`\`bash
docker-compose down
\`\`\`
EOF

echo "Done! cd $PROJECT_NAME && docker-compose up"
