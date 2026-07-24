# Architecture

System design patterns, decision frameworks, and scalability references.

> **Status:** Scaffold — content pending.

---

## Topics to Cover

| Topic | Description |
|---|---|
| **Monolith vs Microservices** | When to split, migration path, trade-offs |
| **Event-Driven Architecture** | Message queues, pub/sub, async processing patterns |
| **Database Design** | Schema design, indexing, migration strategies |
| **Caching Strategies** | Redis patterns: cache-aside, write-through, write-behind |
| **API Design** | REST conventions, versioning, rate limiting, error handling |
| **Authentication** | JWT, OAuth2, session management, RBAC |
| **RAG Pipeline Architecture** | Vector DB, embedding models, retrieval strategies |
| **Observability Architecture** | OpenTelemetry instrumentation, signal correlation |
| **Deployment Patterns** | Blue-green, canary, rolling updates |
| **Scalability** | Horizontal vs vertical, load balancing, connection pooling |

---

## Quick Decision Framework

```
Need shared state?          → Monolith first
Need independent deploys?    → Microservices
Need real-time events?       → Event-driven (Redis Streams / Kafka)
Need to scale reads?         → Read replicas + caching
Need to scale writes?        → Sharding / partitioning
```

---

## Contributing

See [CONTRIBUTING.md](../CONTRIBUTING.md) for cheatsheet format. Architecture guides should follow the same `SCREAMING_SNAKE_CASE.md` naming convention.
