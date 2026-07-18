#!/bin/bash
set -e

PROJECT_NAME="${1:-my-fullstack}"

echo "Generating $PROJECT_NAME..."

mkdir -p "$PROJECT_NAME"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

bash "$SCRIPT_DIR/generate-backend.sh" "$PROJECT_NAME/backend"
bash "$SCRIPT_DIR/generate-frontend.sh" "$PROJECT_NAME/frontend"

cat > "$PROJECT_NAME/docker-compose.yml" << 'EOF'
services:
  frontend:
    build: ./frontend
    ports:
      - "5173:5173"
    environment:
      - VITE_API_URL=http://localhost:8000
      - VITE_USE_MOCK=false
    depends_on:
      - backend

  backend:
    build: ./backend
    ports:
      - "8000:8000"
    env_file: ./backend/.env
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

cat > "$PROJECT_NAME/README.md" << EOF
# $PROJECT_NAME

Full stack: React + FastAPI + PostgreSQL + Redis

## Run

\`\`\`bash
docker-compose up
\`\`\`

## Services

- Frontend: http://localhost:5173
- Backend: http://localhost:8000
- API Docs: http://localhost:8000/docs
- PostgreSQL: localhost:5432
- Redis: localhost:6379

## Stop

\`\`\`bash
docker-compose down -v
\`\`\`
EOF

echo "Done! cd $PROJECT_NAME && docker-compose up"
