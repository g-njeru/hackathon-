# Redis Cheatsheet

Quick reference for common Redis operations and patterns.

---

## Connection

```bash
# Connect to Redis
redis-cli

# Connect via URL
redis-cli -u redis://localhost:6379

# Ping (test connection)
PING

# Quit
QUIT
```

---

## Data Types & Commands

### Strings

```bash
SET key "value"
GET key                        # "value"
SETNX key "value"              # Set if Not Exists (atomic)
SETEX key 3600 "value"         # Set with expiry (seconds)
INCR counter                   # Atomic increment
INCRBY counter 10              # Increment by N
```

### Hashes

```bash
HSET user:1 name "Alice" email "alice@example.com"
HGET user:1 name              # "Alice"
HGETALL user:1                # All fields
HMSET user:1 name "Alice" email "alice@example.com"  # Set multiple
HDEL user:1 email             # Delete field
HEXISTS user:1 name           # Check if field exists
```

### Lists

```bash
LPUSH queue "task1"            # Push to left (front)
RPUSH queue "task2"            # Push to right (back)
LPOP queue                     # Pop from left
RPOP queue                     # Pop from right
LRANGE queue 0 -1              # Get all items
LLEN queue                     # Length
BRPOP queue 30                 # Blocking pop (wait 30s)
```

### Sets

```bash
SADD tags "python" "redis" "hackathon"
SMEMBERS tags                  # All members
SISMEMBER tags "python"        # Check membership (0 or 1)
SCARD tags                     # Count members
SINTER set1 set2               # Intersection
SUNION set1 set2               # Union
SDIFF set1 set2                # Difference
```

### Sorted Sets

```bash
ZADD leaderboard 100 "player1" 200 "player2"
ZRANGE leaderboard 0 -1 WITHSCORES   # All, ascending
ZREVRANGE leaderboard 0 9 WITHSCORES # Top 10
ZSCORE leaderboard "player1"          # Get score
ZRANK leaderboard "player1"           # Get rank (0-indexed)
```

---

## Common Patterns

### Caching

```bash
# Cache with TTL (5 minutes)
SETEX cache:user:123 300 '{"name": "Alice", "score": 100}'

# Check cache first, then fetch from DB
GET cache:user:123
# If nil, fetch from DB, then:
SETEX cache:user:123 300 <json_data>
```

### Rate Limiting (Simple)

```bash
# Increment counter for IP
INCR rate:192.168.1.1
EXPIRE rate:192.168.1.1 60    # Reset after 60 seconds

# Check limit
GET rate:192.168.1.1
# If > 100, reject request
```

### Pub/Sub

```bash
# Subscriber
SUBSCRIBE channel1

# Publisher
PUBLISH channel1 "hello world"

# Pattern subscribe
PSUBSCRIBE news:*
```

### Sessions

```bash
# Store session
HSET session:abc123 user_id "1" role "admin" expires_at "1700000000"
EXPIRE session:abc123 3600

# Validate session
HGETALL session:abc123

# Destroy session
DEL session:abc123
```

---

## Python Integration (redis-py)

```python
import redis

# Connect
r = redis.Redis(host='localhost', port=6379, db=0, decode_responses=True)

# String operations
r.set('key', 'value', ex=300)  # 5 min TTL
value = r.get('key')

# Hash operations
r.hset('user:1', mapping={'name': 'Alice', 'score': 100})
user = r.hgetall('user:1')

# List operations
r.lpush('queue', 'task1')
task = r.rpop('queue')

# Check if key exists
if r.exists('cache:user:123'):
    data = r.get('cache:user:123')
```

---

## Docker Compose Quick Reference

```yaml
services:
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redisdata:/data

volumes:
  redisdata:
```

---

## When to Use Redis

| Use Case | Pattern | Why Redis |
|---|---|---|
| Session storage | Hash | Fast reads, TTL for expiry |
| Caching | String + TTL | Sub-millisecond reads |
| Rate limiting | INCR + EXPIRE | Atomic operations |
| Task queues | List (LPUSH/BRPOP) | Reliable, blocking pop |
| Real-time leaderboards | Sorted Set | Automatic ranking |
| Pub/Sub | SUBSCRIBE/PUBLISH | Lightweight messaging |
