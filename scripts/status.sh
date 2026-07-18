#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

check_port() {
    local port=$1
    local name=$2
    if curl -s -o /dev/null --max-time 2 "http://localhost:$port" 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} $name (port $port)"
        return 0
    else
        echo -e "  ${RED}✗${NC} $name (port $port)"
        return 1
    fi
}

echo "Service Status"
echo "=============="
echo ""

# Check Docker
if command -v docker &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} Docker installed"
else
    echo -e "  ${RED}✗${NC} Docker not found"
fi

# Check running containers
containers=$(docker ps --format "{{.Names}}" 2>/dev/null)
if [ -n "$containers" ]; then
    echo ""
    echo "Running containers:"
    docker ps --format "  {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null
else
    echo ""
    echo -e "  ${YELLOW}No running containers${NC}"
fi

echo ""
echo "Endpoints:"
check_port 5173 "Frontend"
check_port 8000 "Backend"
check_port 3000 "Grafana"
check_port 5432 "PostgreSQL"
check_port 6379 "Redis"
check_port 3100 "Loki"
check_port 9090 "Prometheus"
