# FOSS Security Stack & Observability Guide

End-to-end telemetry, application security, and threat defense using free and open-source tools.

---

## Stack Overview

| Domain | Primary Tool | Output |
|---|---|---|
| Observability, Tracing & Audit | OpenObserve | Unified latency waterfalls, token cost tracking, user query logs |
| System Integrity & Compliance | Wazuh | Alerts on modified files, unauthorized root access, OS CVEs |
| Edge Defense & Bot Protection | CrowdSec | Automatic IP bans at firewall for abusive traffic |
| Supply Chain Security | Trivy | Pre-deployment report of vulnerable Python/Node libraries |
| Penetration Testing | OWASP ZAP | HTML reports with API vulnerabilities and code-level fixes |

---

## 1. OpenObserve — System-Wide Telemetry

Correlates telemetry across every layer:

| Layer | What to track |
|---|---|
| **Scrapy (Web Scraper)** | Crawl status, rate limits (429), anti-bot blocks (403), document parsing bottlenecks |
| **Redis (Cache/Queue)** | Cache hits/misses, execution latency, background worker queue depth |
| **FastAPI (Backend)** | HTTP request latency, vector DB search timing, LLM response times, unhandled exceptions |
| **React / React Native** | Real User Monitoring (RUM) events, client-side JS crashes, screen render times |
| **RAG Pipeline** | Prompt/completion token usage, API cost breakdown, vector retrieval latency |

See [OPENOBSERVE_GUIDE.md](../observability/OPENOBSERVE_GUIDE.md) for setup.

---

## 2. Wazuh — Host & Endpoint SIEM/XDR

Monitors Linux OS, Docker, SSH, and databases.

### Key Features

- **File Integrity Monitoring (FIM)** — detects unauthorized file changes
- **Vulnerability scanning** — OS and package CVE detection
- **Active response** — automatic firewall blocks on threat detection
- **Log analysis** — parses system logs for indicators of compromise

### Quick Setup (Docker)

```bash
docker compose -f https://raw.githubusercontent.com/wazuh/wazuh-docker/4.x/docker-compose.yml up -d
```

Default dashboard: `https://localhost:443` (admin/admin).

---

## 3. CrowdSec — Automated Intrusion Blocking

Crowdsourced threat intelligence — detects and blocks brute-force, bad bots, and API scrapers.

### How It Works

1. Parses logs (Nginx, FastAPI, system logs)
2. Detects aggressive behavior patterns
3. Shares threat intel with CrowdSec network
4. Automatically bans offending IPs at firewall level

### Quick Setup

```bash
# Install
curl -s https://install.crowdsec.sh | bash

# Enroll
sudo cscli console enroll <YOUR_ENROLLMENT_KEY>

# Add bouncer (firewall)
sudo apt install crowdsec-firewall-bouncer-iptables
```

### Common Parsers

| Parser | Use case |
|---|---|
| `crowdsecurity/nginx` | Nginx access logs |
| `crowdsecurity/sshd` | SSH brute-force detection |
| `crowdsecurity/http-crawl-non_statics` | Bot detection |

---

## 4. Trivy — Container & Dependency Scanner

Scans Docker images, `requirements.txt`, `package.json`, and IaC configs for known CVEs.

### Install

```bash
# macOS
brew install trivy

# Linux
sudo apt install trivy
```

### Scan Commands

```bash
# Scan container image
trivy image myapp:latest

# Scan filesystem (dependencies)
trivy fs .

# Scan with all scanners
trivy fs --scanners vuln,secret,config .

# Scan Dockerfile for misconfigurations
trivy config Dockerfile

# Exclude low-severity
trivy image --severity HIGH,CRITICAL myapp:latest
```

### CI/CD Integration (GitHub Actions)

```yaml
- name: Run Trivy vulnerability scanner
  uses: aquasecurity/trivy-action@master
  with:
    image-ref: myapp:latest
    format: table
    severity: HIGH,CRITICAL
    exit-code: 1
```

---

## 5. OWASP ZAP — API & Application Security Scanner

Automated penetration testing for authentication flaws, CORS, SQL injection, and data leakage.

### Quick Scan (Docker)

```bash
# Baseline scan
docker run -t owasp/zap2docker-stable zap-baseline.py \
  -t http://localhost:8000/docs

# Full scan
docker run -t owasp/zap2docker-stable zap-full-scan.py \
  -t http://localhost:8000/docs

# API scan (OpenAPI)
docker run -t owasp/zap2docker-stable zap-api-scan.py \
  -t http://localhost:8000/openapi.json \
  -f openapi
```

### ZAP CLI

```bash
pip install zapv2
```

```python
from zapv2 import ZAPv2

zap = ZAPv2(apikey='your-api-key', proxies={'http': 'http://127.0.0.1:8080'})

# Spider the target
zap.urlopen('http://localhost:8000')
zap.spider.scan('http://localhost:8000')

# Active scan
zap.ascan.scan('http://localhost:8000')

# Get alerts
alerts = zap.core.alerts()
for alert in alerts:
    print(f"{alert['alert']}: {alert['url']}")
```

---

## Architecture Matrix

| Security Domain | Tool | What it catches |
|---|---|---|
| **Audit trails** | OpenObserve | Latency spikes, token costs, query logs |
| **File tampering** | Wazuh | Modified server files, unauthorized root access |
| **Brute-force / bots** | CrowdSec | Login attempts, scraping IPs |
| **Vulnerable deps** | Trivy | Known CVEs in Python/Node libraries |
| **App vulnerabilities** | OWASP ZAP | SQLi, XSS, CORS, auth flaws |

---

## Hackathon Priority

| Phase | Tool | Why |
|---|---|---|
| **Day 1** | Trivy | Scan deps before deploying — 2 min |
| **Day 2** | OpenObserve | Logs + metrics from day one |
| **Day 3** | OWASP ZAP | Quick API scan before demo |
| **Post-MVP** | Wazuh + CrowdSec | Production hardening |

---

## Common Gotchas

| Gotcha | Solution |
|---|---|
| ZAP scan slows dev server | Use `--hook` script or scan staging, not local |
| Trivy false positives | Use `--ignore-unfixed` to skip not-yet-patched CVEs |
| CrowdSec blocks your own IP | Whitelist your IP: `sudo cscli decisions add --ip YOUR_IP --duration 0` |
| Wazuh agent not connecting | Check agent enrollment key and port 1514/1515 |

---

## Further Reading

- [FOSS Security Stack (full doc)](../reference/pdfs/FOSS%20Security%20Stack%20&%20Observability%20Guide%20for%20AI-Driven%20Applications.docx)
- [Wazuh Docs](https://documentation.wazuh.com)
- [CrowdSec Docs](https://doc.crowdsec.net)
- [Trivy Docs](https://aquasecurity.github.io/trivy)
- [OWASP ZAP Docs](https://www.zaproxy.org/docs/)
