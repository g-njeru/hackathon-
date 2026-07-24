# LGTM Stack Guide

FOSS monitoring with Loki, Grafana, Tempo, and Mimir.

> **Looking for something lighter?** See [OpenObserve](OPENOBSERVE_GUIDE.md) — a single Rust binary that replaces the entire LGTM stack with unified logs, metrics, and traces. Lower resource footprint, SQL queries, 40x Parquet compression.

---

## What is the LGTM Stack?

| Tool | Purpose | Replaces |
|---|---|---|
| **Loki** | Log aggregation | ELK Stack, Datadog Logs |
| **Grafana** | Dashboards & visualization | Datadog Dashboards |
| **Tempo** | Distributed tracing | Datadog APM, Jaeger |
| **Mimir** | Long-term metrics storage | Datadog Metrics, Prometheus |

Together, they give you a **full observability stack** without paying for SaaS.

---

## Quick Setup (Docker Compose)

```yaml
services:
  # Grafana — Dashboards
  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana_data:/var/lib/grafana

  # Loki — Logs
  loki:
    image: grafana/loki:latest
    ports:
      - "3100:3100"
    command: -config.file=/etc/loki/local-config.yaml

  # Tempo — Traces
  tempo:
    image: grafana/tempo:latest
    ports:
      - "3200:3200"
    command: [ "-config.file=/etc/tempo/tempo.yaml" ]

  # Prometheus — Metrics (feeds Mimir)
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml

volumes:
  grafana_data:
```

Save as `docker-compose-lgtm.yml` and run:

```bash
docker-compose -f docker-compose-lgtm.yml up -d
```

Access Grafana at `http://localhost:3000` (admin/admin).

---

## Connect FastAPI to Loki (Logs)

### Install Python client

```bash
pip install python-logging-loki
```

### Configure logging

```python
import logging
from logging.handlers import HTTPHandler

# Send logs to Loki
handler = HTTPHandler(
    host="localhost:3100",
    url="/loki/api/v1/push",
    method="POST",
)

logger = logging.getLogger("fastapi")
logger.addHandler(handler)
logger.setLevel(logging.INFO)

# Use it
logger.info("User logged in", extra={"user_id": "123"})
```

### Or use structlog

```bash
pip install structlog
```

```python
import structlog
import logging

# Configure structlog to send to Loki
structlog.configure(
    processors=[
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.JSONRenderer()
    ],
    wrapper_class=structlog.BoundLogger,
    context_class=dict,
    logger_factory=structlog.PrintLoggerFactory(),
)

log = structlog.get_logger()
log.info("document_created", doc_id="abc-123", user_id="user-1")
```

---

## Connect FastAPI to Tempo (Traces)

### Install OpenTelemetry

```bash
pip install opentelemetry-api opentelemetry-sdk opentelemetry-exporter-otlp opentelemetry-instrumentation-fastapi
```

### Instrument FastAPI

```python
from fastapi import FastAPI
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.http.trace_exporter import OTLPSpanExporter
from opentelemetry.instrumentation.fastapi import FastAPIMiddleware

app = FastAPI()

# Setup tracing
provider = TracerProvider()
processor = BatchSpanProcessor(OTLPSpanExporter(endpoint="http://localhost:4318"))
provider.add_span_processor(processor)
trace.set_tracer_provider(provider)

# Add middleware
app.add_middleware(FastAPIMiddleware)

@app.get("/documents")
async def list_documents():
    tracer = trace.get_tracer(__name__)
    with tracer.start_as_current_span("list_documents"):
        # Your logic here
        return {"documents": []}
```

---

## Connect FastAPI to Prometheus (Metrics)

### Install

```bash
pip install prometheus-fastapi-instrumentator
```

### Instrument

```python
from fastapi import FastAPI
from prometheus_fastapi_instrumentator import Instrumentator

app = FastAPI()
Instrumentator().instrument(app).expose(app)

@app.get("/documents")
async def list_documents():
    return {"documents": []}
```

This automatically exposes metrics at `/metrics`:
- Request count
- Request duration
- Response status codes

---

## Grafana Data Sources

After starting the stack, add data sources in Grafana:

1. Go to `http://localhost:3000`
2. Settings → Data Sources → Add
3. Add:
   - **Loki**: `http://loki:3100`
   - **Tempo**: `http://tempo:3200`
   - **Prometheus**: `http://prometheus:9090`

---

## Query Examples

### Loki (Logs)

```logql
# All logs from FastAPI
{app="fastapi"}

# Error logs
{app="fastapi"} |~ "error"

# Logs from specific endpoint
{app="fastapi"} | json | path="/documents"
```

### Tempo (Traces)

Search by service name or trace ID in Grafana's Tempo data source.

### Prometheus (Metrics)

```promql
# Request rate
rate(http_requests_total[5m])

# 95th percentile latency
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))

# Error rate
rate(http_requests_total{status=~"5.."}[5m])
```

---

## When to Use What

| Signal | Use for | LGTM Tool |
|---|---|---|
| **Logs** | Debug errors, audit trail | Loki |
| **Metrics** | Performance monitoring, alerts | Prometheus/Mimir |
| **Traces** | Understand request flow, find bottlenecks | Tempo |

---

## Hackathon Setup

For a hackathon, you don't need all four. Start with:

1. **Grafana + Loki** — logs and basic dashboards (30 min setup)
2. Add **Prometheus** if you need metrics (15 min)
3. Add **Tempo** only if you have microservices (skip for monolith)

```bash
# Minimal setup — just logs
docker-compose -f docker-compose-lgtm.yml up -d grafana loki
```
