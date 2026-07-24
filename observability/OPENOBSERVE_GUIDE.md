# OpenObserve Guide

Lightweight, unified observability — logs, metrics, and traces in a single Rust binary.

---

## What is OpenObserve?

A FOSS alternative to the full LGTM stack. Replaces Loki + Grafana + Tempo + Mimir with one engine running on Apache Parquet / ClickHouse columnar storage.

| Feature | LGTM Stack | OpenObserve |
|---|---|---|
| **Components** | 4–6 separate services | Single binary |
| **Storage** | Inverted indexes, JVM/Go chunk stores | Columnar Parquet (up to 40x compression) |
| **Query languages** | LogQL + PromQL + TraceQL | SQL or VRL (unified) |
| **Resource footprint** | High (multiple JVM/Go processes) | Low (Rust, stateless) |
| **Docker images** | 4+ containers | 1 container |

### When to pick OpenObserve over LGTM

- Solo dev / small team — less operational overhead
- Cost-sensitive — minimal RAM/CPU, S3-compatible storage
- Want unified querying across all signals
- Don't need Grafana's massive plugin ecosystem

### When LGTM still wins

- Enterprise multi-tenancy at scale
- Thousands of pre-built Grafana dashboards
- 100+ non-observability data source integrations

---

## Quick Setup (Docker)

```bash
docker run -d \
  --name openobserve \
  -p 5080:5080 \
  -v ~/openobserve_data:/data \
  -e ZO_DATA_RETENTION_DAYS=7 \
  -e ZO_ROOT_USER_EMAIL=admin@example.com \
  -e ZO_ROOT_USER_PASSWORD=YourSecurePassword123! \
  openobserve/openobserve:latest
```

**Password requirements:** Uppercase + lowercase + numbers + special characters.

Access at `http://localhost:5080`.

---

## Docker Compose

```yaml
services:
  openobserve:
    image: openobserve/openobserve:latest
    ports:
      - "5080:5080"
    volumes:
      - openobserve_data:/data
    environment:
      - ZO_DATA_RETENTION_DAYS=7
      - ZO_ROOT_USER_EMAIL=admin@example.com
      - ZO_ROOT_USER_PASSWORD=YourSecurePassword123!

volumes:
  openobserve_data:
```

---

## Connect FastAPI (Logs + Traces)

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

# Traces → OpenObserve
provider = TracerProvider()
processor = BatchSpanProcessor(
    OTLPSpanExporter(endpoint="http://localhost:5080/api/default/traces")
)
provider.add_span_processor(processor)
trace.set_tracer_provider(provider)

app.add_middleware(FastAPIMiddleware)
```

### Send logs via HTTP

```bash
curl -X POST http://localhost:5080/api/default/test_stream/_json \
  -H "Content-Type: application/json" \
  -d '[{"level":"info","message":"User logged in","user_id":"123"}]'
```

---

## Ingestion Endpoints

| Signal | Endpoint | Protocol |
|---|---|---|
| Logs (JSON) | `/api/default/{stream}/_json` | HTTP POST |
| Logs (syslog) | `/api/default/{stream}/_syslog` | HTTP POST |
| Metrics | `/api/default/{stream}/_metrics` | Prometheus remote-write |
| Traces | `/api/default/traces` | OTLP (gRPC/HTTP) |

---

## Query Examples

### SQL queries

```sql
-- All logs from a stream
SELECT * FROM default.test_stream

-- Error logs
SELECT * FROM default.test_stream WHERE level = 'error'

-- Request count by status code
SELECT status_code, COUNT(*) as count
FROM default.fastapi_logs
GROUP BY status_code
ORDER BY count DESC
```

### VRL (Vector Remap Language)

```vrl
# Filter and transform
.level == "error" | .message = upcase(.message)
```

---

## Useful Queries

| What | Query |
|---|---|
| All logs | `SELECT * FROM {stream}` |
| Errors only | `WHERE level = 'error'` |
| Slow requests | `WHERE duration > 1.0` |
| Recent (5 min) | `WHERE _timestamp > now() - interval '5 minutes'` |

---

## Local Setup Checklist

| Component | Status | Endpoint |
|---|---|---|
| OpenObserve Engine | Active | `http://localhost:5080` |
| Persistent Data | `~/openobserve_data` | — |
| Retention | 7 days auto-prune | `ZO_DATA_RETENTION_DAYS=7` |
| Health Check | `GET /healthz` | Returns `200 OK` |

---

## Troubleshooting

| Problem | Fix |
|---|---|
| Container panic on startup | Password must include uppercase, lowercase, numbers, special chars |
| Image pull fails | Use `openobserve/openobserve:latest` from Docker Hub |
| No data showing | Check ingestion endpoint URL and stream name |
| Disk bloat | Set `ZO_DATA_RETENTION_DAYS` (default: keep forever) |

---

## Common Gotchas

| Gotcha | Solution |
|---|---|
| Default password rejected | Must be complex: `YourSecurePassword123!` |
| Port 5080 conflict | Change `-p` mapping or stop conflicting service |
| Data lost after container recreate | Mount volume to `/data` |
| Grafana UI preferred | OpenObserve has an official Grafana plugin — use O2 as backend, Grafana as frontend |

---

## Further Reading

- [OpenObserve Docs](https://openobserve.ai/docs)
- [LGTM vs OpenObserve](../reference/pdfs/OpenObserve%20vs%20Grafana.docx)
- [Local Setup Details](../reference/pdfs/Local%20Observability%20&%20OpenObserve%20Setup%20Summary.docx)
