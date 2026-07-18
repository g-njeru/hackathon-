#!/bin/bash
set -e

URL="${1}"
INTERVAL="${2:-300}"

if [ -z "$URL" ]; then
    echo "Usage: bash keep-alive.sh <url> [interval_seconds]"
    echo ""
    echo "Keeps a free-tier service alive by pinging it periodically."
    echo ""
    echo "Examples:"
    echo "  bash keep-alive.sh https://my-app.fly.dev"
    echo "  bash keep-alive.sh https://my-app.fly.dev 60"
    echo ""
    echo "Press Ctrl+C to stop."
    exit 1
fi

echo "Keep-alive: $URL"
echo "Interval: ${INTERVAL}s"
echo "Press Ctrl+C to stop"
echo ""

count=0
while true; do
    count=$((count + 1))
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    status=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "$URL" 2>/dev/null || echo "000")

    if [ "$status" -ge 200 ] && [ "$status" -lt 400 ]; then
        echo "[$timestamp] #$count  ✓ $status"
    else
        echo "[$timestamp] #$count  ✗ $status"
    fi

    sleep "$INTERVAL"
done
