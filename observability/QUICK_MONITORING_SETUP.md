# Quick Monitoring Setup

Minimal Grafana dashboards for hackathon projects. Get visibility in 15 minutes.

---

## What to Monitor

For a hackathon, you need three things:

1. **Is the app up?** — Health check monitoring
2. **Is it fast?** — Latency metrics
3. **Is it breaking?** — Error rates

Don't over-engineer monitoring. If it's not broken, you don't need a dashboard.

---

## Step 1: Health Check Dashboard (5 minutes)

### Add to FastAPI

```python
@app.get("/health")
async def health():
    return {"status": "ok", "version": "0.1.0"}

@app.get("/health/ready")
async def ready(db: AsyncSession = Depends(get_db)):
    try:
        await db.execute(text("SELECT 1"))
        return {"status": "ready", "database": "connected"}
    except Exception:
        raise HTTPException(status_code=503, detail="Database not ready")
```

### Simple monitoring script

```python
# monitor.py
import requests
import time

SERVICES = [
    {"name": "Backend", "url": "http://localhost:8000/health"},
    {"name": "Frontend", "url": "http://localhost:5173"},
    {"name": "Database", "url": "http://localhost:8000/health/ready"},
]

while True:
    for service in SERVICES:
        try:
            response = requests.get(service["url"], timeout=5)
            status = "UP" if response.status_code == 200 else "DOWN"
        except requests.RequestException:
            status = "DOWN"
        print(f"{service['name']}: {status}")
    time.sleep(60)
```

---

## Step 2: Prometheus Metrics (10 minutes)

### Install

```bash
pip install prometheus-fastapi-instrumentator
```

### Add to FastAPI

```python
from prometheus_fastapi_instrumentator import Instrumentator

app = FastAPI()
Instrumentator().instrument(app).expose(app)
```

### Docker Compose

```yaml
services:
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=admin
```

### prometheus.yml

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: "fastapi"
    static_configs:
      - targets: ["host.docker.internal:8000"]
```

---

## Step 3: Grafana Dashboard (5 minutes)

### Import pre-built dashboard

1. Go to Grafana → Dashboards → Import
2. Use dashboard ID: **14252** (FastAPI)
3. Select Prometheus data source
4. Click Import

### What you'll see

- Request rate (req/s)
- Response time (p50, p95, p99)
- Error rate (4xx, 5xx)
- Active requests

---

## Step 4: Alert on Errors (Optional)

### Grafana alert rule

1. Go to Alerting → Alert Rules → New
2. Set condition: `rate(http_requests_total{status=~"5.."}[5m]) > 0.1`
3. Set notification channel (email, Slack, Discord)
4. Save

### Simple Slack alert

```python
import requests

def send_alert(message: str):
    webhook_url = "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
    requests.post(webhook_url, json={"text": message})

# In your error handler
@app.exception_handler(Exception)
async def global_handler(request, exc):
    send_alert(f"Error: {exc}")
    return JSONResponse(status_code=500, content={"detail": "Internal error"})
```

---

## Minimal Stack (Hackathon)

For a hackathon, this is enough:

```yaml
services:
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=admin
```

This gives you:
- Metrics collection (Prometheus)
- Visualization (Grafana)
- Basic alerting (Grafana alerts)

**Skip Loki and Tempo** unless you specifically need log search or distributed tracing.

---

## Quick Commands

```bash
# Start monitoring stack
docker-compose up -d prometheus grafana

# Check Prometheus targets
curl http://localhost:9090/targets

# Check Grafana
open http://localhost:3000
```

---

## What NOT to Monitor in a Hackathon

- Individual function performance (too granular)
- Memory usage per container (not actionable)
- Network latency between services (premature)
- Custom business metrics (focus on shipping)

Focus on: **Is it up? Is it fast? Is it breaking?**
