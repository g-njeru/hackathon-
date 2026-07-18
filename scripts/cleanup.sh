#!/bin/bash

echo "Cleaning up Docker resources..."
echo ""

# Stop containers in current directory
if [ -f "docker-compose.yml" ] || [ -f "docker-compose.yaml" ]; then
    echo "Stopping docker-compose services..."
    docker-compose down -v 2>/dev/null || docker compose down -v 2>/dev/null || true
fi

# Stop containers in subdirectories
for dir in */; do
    if [ -f "${dir}docker-compose.yml" ] || [ -f "${dir}docker-compose.yaml" ]; then
        echo "Stopping services in $dir..."
        (cd "$dir" && docker-compose down -v 2>/dev/null || docker compose down -v 2>/dev/null || true)
    fi
done

echo ""
echo "Removing dangling images..."
docker image prune -f 2>/dev/null || true

echo ""
echo "Cleaning build cache..."
docker builder prune -f 2>/dev/null || true

echo ""
echo "Done. Disk usage:"
docker system df 2>/dev/null || true
