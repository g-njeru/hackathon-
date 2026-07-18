# Docker Cheatsheet

Quick reference for Docker and Docker Compose.

---

## Docker Commands

```bash
# Build
docker build -t myapp .

# Run
docker run -p 8000:8000 myapp

# Run in background
docker run -d -p 8000:8000 myapp

# List running containers
docker ps

# List all containers
docker ps -a

# Stop container
docker stop <container_id>

# Remove container
docker rm <container_id>

# Remove image
docker rmi <image_id>

# View logs
docker logs <container_id>

# Follow logs
docker logs -f <container_id>

# Execute command in container
docker exec -it <container_id> /bin/bash

# Clean up unused resources
docker system prune -a
```

---

## Dockerfile Patterns

### Python (FastAPI)

```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install dependencies first (cache layer)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy app code
COPY . .

EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Node.js (React/Vite)

```dockerfile
FROM node:20-alpine

WORKDIR /app

COPY package*.json .
RUN npm ci

COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=0 /app/dist /usr/share/nginx/html
EXPOSE 80
```

### Multi-stage build (Python)

```dockerfile
# Build stage
FROM python:3.11-slim as builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Runtime stage
FROM python:3.11-slim
WORKDIR /app
COPY --from=builder /root/.local /root/.local
COPY . .
ENV PATH=/root/.local/bin:$PATH
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

---

## Docker Compose

### Basic structure

```yaml
services:
  app:
    build: .
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://postgres:password@db:5432/hackathon
    depends_on:
      - db
      - redis

  db:
    image: postgres:16
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
      POSTGRES_DB: hackathon
    volumes:
      - pgdata:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

volumes:
  pgdata:
```

### Common commands

```bash
# Start all services
docker-compose up

# Start in background
docker-compose up -d

# Stop all services
docker-compose down

# Rebuild images
docker-compose up --build

# View logs
docker-compose logs -f

# View logs for specific service
docker-compose logs -f app

# Execute command in service
docker-compose exec app bash

# Scale a service
docker-compose up --scale worker=3
```

### Environment variables

```yaml
services:
  app:
    env_file:
      - .env
    environment:
      - DEBUG=true
      - NODE_ENV=development
```

### Volumes

```yaml
services:
  app:
    volumes:
      - ./src:/app/src          # Bind mount (dev)
      - node_modules:/app/node_modules  # Named volume

volumes:
  node_modules:
```

### Health checks

```yaml
services:
  db:
    image: postgres:16
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5

  app:
    depends_on:
      db:
        condition: service_healthy
```

---

## .dockerignore

```
node_modules
.git
.env
__pycache__
*.pyc
dist
build
.venv
```

---

## Common Gotchas

| Issue | Fix |
|---|---|
| Container can't connect to host | Use `host.docker.internal` instead of `localhost` |
| Slow builds | Use `.dockerignore`, copy `requirements.txt` before code |
| Container exits immediately | Check `docker logs <container>` — usually a startup error |
| Port already in use | `docker-compose down` or change the port mapping |
| Changes not reflecting | Use bind mounts for dev, rebuild with `--build` |
