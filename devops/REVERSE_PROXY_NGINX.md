# Nginx Reverse Proxy

Use Nginx to route traffic, serve static files, and handle SSL for hackathon demos.

---

## When to Use Nginx

- Reverse proxy to backend API (hide port numbers)
- Serve frontend static files
- SSL termination (HTTPS)
- Load balancing multiple instances
- Demo day polish (looks professional)

---

## Basic Setup

### Install

```bash
# Ubuntu/Debian
sudo apt install nginx

# macOS
brew install nginx

# Docker
docker run -d -p 80:80 nginx
```

### Config location

- Ubuntu: `/etc/nginx/sites-available/default`
- macOS: `/opt/homebrew/etc/nginx/nginx.conf`
- Docker: `/etc/nginx/conf.d/default.conf`

---

## Reverse Proxy

### Proxy to FastAPI

```nginx
server {
    listen 80;
    server_name myapp.com;

    # Frontend static files
    location / {
        root /var/www/frontend/dist;
        try_files $uri $uri/ /index.html;
    }

    # Backend API
    location /api/ {
        proxy_pass http://127.0.0.1:8000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### Multiple backends

```nginx
upstream api_servers {
    server 127.0.0.1:8000;
    server 127.0.0.1:8001;
}

server {
    listen 80;

    location /api/ {
        proxy_pass http://api_servers/;
    }
}
```

---

## Serve Static Files

```nginx
server {
    listen 80;
    server_name myapp.com;

    root /var/www/frontend/dist;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /assets/ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

---

## SSL with Let's Encrypt

```bash
# Install certbot
sudo apt install certbot python3-certbot-nginx

# Get certificate
sudo certbot --nginx -d myapp.com

# Auto-renew
sudo certbot renew --dry-run
```

### Manual SSL config

```nginx
server {
    listen 443 ssl;
    server_name myapp.com;

    ssl_certificate /etc/letsencrypt/live/myapp.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/myapp.com/privkey.pem;

    # ... rest of config
}

server {
    listen 80;
    server_name myapp.com;
    return 301 https://$host$request_uri;
}
```

---

## WebSocket Proxy

```nginx
location /ws/ {
    proxy_pass http://127.0.0.1:8000/;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $host;
}
```

---

## Docker Compose with Nginx

```yaml
services:
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/conf.d/default.conf
      - ./frontend/dist:/var/www/frontend/dist
      - ./certs:/etc/letsencrypt
    depends_on:
      - app

  app:
    build: .
    expose:
      - "8000"
```

---

## Hackathon Demo Setup

For a polished demo, use Nginx to:

1. **Serve frontend on port 80** (no port number in URL)
2. **Proxy `/api/` to FastAPI** (clean URL structure)
3. **Serve static assets with caching** (fast page loads)

```nginx
server {
    listen 80;
    server_name demo.hackathon.com;

    root /var/www/dist;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /api/ {
        proxy_pass http://127.0.0.1:8000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location /assets/ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

---

## Quick Commands

```bash
# Test config
sudo nginx -t

# Reload config
sudo nginx -s reload

# Start
sudo systemctl start nginx

# Stop
sudo systemctl stop nginx

# View logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

---

## Common Gotchas

| Issue | Fix |
|---|---|
| 502 Bad Gateway | Backend isn't running or wrong port |
| 403 Forbidden | Check file permissions on static files |
| WebSocket not connecting | Add `Upgrade` and `Connection` headers |
| Changes not applying | Run `nginx -s reload` |
| Port 80 already in use | Stop Apache: `sudo systemctl stop apache2` |
