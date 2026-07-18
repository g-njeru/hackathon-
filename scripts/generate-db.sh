#!/bin/bash
set -e

PROJECT_NAME="${1:-my-db}"

echo "Generating $PROJECT_NAME..."

mkdir -p "$PROJECT_NAME"

cat > "$PROJECT_NAME/docker-compose.yml" << 'EOF'
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

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

volumes:
  pgdata:
EOF

cat > "$PROJECT_NAME/.env.example" << 'EOF'
DATABASE_URL=postgresql://postgres:password@localhost:5432/hackathon
REDIS_URL=redis://localhost:6379
EOF

cat > "$PROJECT_NAME/README.md" << EOF
# $PROJECT_NAME

PostgreSQL 16 + Redis 7

## Run

\`\`\`bash
docker-compose up -d
\`\`\`

## Services

- PostgreSQL: localhost:5432
- Redis: localhost:6379

## Connect

\`\`\`bash
psql -U postgres -d hackathon
redis-cli
\`\`\`

## Stop

\`\`\`bash
docker-compose down -v
\`\`\`
EOF

echo "Done! cd $PROJECT_NAME && docker-compose up -d"
