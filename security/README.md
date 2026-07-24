# Security

FOSS security tools for application protection, vulnerability scanning, and threat defense.

## Tools

| Tool | Purpose | Guide |
|---|---|---|
| **Wazuh** | Host SIEM/XDR — endpoint threat detection | [FOSS_SECURITY_STACK.md](FOSS_SECURITY_STACK.md) |
| **CrowdSec** | Automated intrusion blocking | [FOSS_SECURITY_STACK.md](FOSS_SECURITY_STACK.md) |
| **Trivy** | Container & dependency vulnerability scanner | [FOSS_SECURITY_STACK.md](FOSS_SECURITY_STACK.md) |
| **OWASP ZAP** | API & web app security scanner | [FOSS_SECURITY_STACK.md](FOSS_SECURITY_STACK.md) |

## Quick Start

```bash
# Scan container for CVEs
trivy image myapp:latest

# Scan dependencies
trivy fs .

# Scan code
trivy fs --scanners vuln,secret,config .
```
