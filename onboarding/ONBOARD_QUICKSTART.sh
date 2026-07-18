#!/bin/bash
# Quick Start Script — Set up the full dev environment in one command
# Usage: bash onboarding/ONBOARD_QUICKSTART.sh

set -e

echo "🚀 Hackathon Quick Start"
echo "========================"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if command exists
check_command() {
    if command -v "$1" &> /dev/null; then
        echo -e "${GREEN}✓${NC} $1 is installed"
        return 0
    else
        echo -e "${RED}✗${NC} $1 is NOT installed"
        return 1
    fi
}

echo ""
echo "Checking prerequisites..."

MISSING=0

if ! check_command git; then MISSING=1; fi
if ! check_command node; then MISSING=1; fi
if ! check_command python3; then MISSING=1; fi
if ! check_command docker; then MISSING=1; fi

if [ $MISSING -eq 1 ]; then
    echo ""
    echo -e "${YELLOW}Missing tools detected.${NC}"
    echo "Install them before continuing:"
    echo "  - Git: https://git-scm.com"
    echo "  - Node.js: https://nodejs.org"
    echo "  - Python: https://python.org"
    echo "  - Docker: https://docker.com"
    exit 1
fi

echo ""
echo "All prerequisites installed!"

# Check if .env exists, copy from example if not
if [ ! -f .env ]; then
    if [ -f .env.example ]; then
        cp .env.example .env
        echo -e "${GREEN}✓${NC} Created .env from .env.example"
        echo -e "${YELLOW}⚠${NC}  Edit .env with your actual values before running the stack"
    else
        echo -e "${YELLOW}⚠${NC}  No .env.example found — you'll need to create .env manually"
    fi
else
    echo -e "${GREEN}✓${NC} .env already exists"
fi

# Install frontend dependencies
if [ -d frontend ]; then
    echo ""
    echo "Installing frontend dependencies..."
    (cd frontend && npm install)
    echo -e "${GREEN}✓${NC} Frontend dependencies installed"
fi

# Install backend dependencies
if [ -d backend ]; then
    echo ""
    echo "Installing backend dependencies..."
    (cd backend && pip install -r requirements.txt 2>/dev/null || pip install -r requirements.txt)
    echo -e "${GREEN}✓${NC} Backend dependencies installed"
fi

# Start Docker services
echo ""
echo "Starting Docker services..."
docker-compose up -d

echo ""
echo "========================================="
echo -e "${GREEN}Setup complete!${NC}"
echo "========================================="
echo ""
echo "Services running:"
echo "  - Frontend:  http://localhost:5173"
echo "  - Backend:   http://localhost:8000"
echo "  - PostgreSQL: localhost:5432"
echo "  - Redis:      localhost:6379"
echo ""
echo "Next steps:"
echo "  1. Edit .env with your actual values"
echo "  2. Read onboarding/TEAM_ONBOARDING.md"
echo "  3. Read hackathon_playbook/TEAM_WORKFLOWS.md"
echo ""
echo "Happy hacking! 🎉"
