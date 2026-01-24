# Redis Caching

Configure Redis for session storage and caching.

## Why Use Redis?

- **Session storage** - Share sessions across multiple Authority instances
- **Token caching** - Faster token validation
- **Rate limiting** - Distributed rate limit counters

## Prerequisites

- Redis 6.0+
- Network access between Authority and Redis

## Basic Setup

### Install Redis

**Docker:**
```bash
docker run -d -p 6379:6379 redis:7-alpine
```

**macOS:**
```bash
brew install redis
brew services start redis
```

**Ubuntu:**
```bash
sudo apt install redis-server
sudo systemctl enable redis
sudo systemctl start redis
```

### Configure Authority

Set the Redis URL:

```bash
REDIS_URL=redis://localhost:6379
```

With password:

```bash
REDIS_URL=redis://:password@localhost:6379
```

With database number:

```bash
REDIS_URL=redis://localhost:6379/1
```

## Production Configuration

### Redis Configuration

```conf
# redis.conf

# Memory
maxmemory 256mb
maxmemory-policy allkeys-lru

# Persistence
save 900 1
save 300 10
save 60 10000

# Security
requirepass your_redis_password
bind 127.0.0.1

# Performance
tcp-keepalive 300
```

### TLS/SSL

```bash
REDIS_URL=rediss://user:password@redis.example.com:6380
```

## Docker Compose

```yaml
version: '3.8'

services:
  authority:
    image: azutoolkit/authority
    environment:
      - REDIS_URL=redis://redis:6379
    depends_on:
      - redis

  redis:
    image: redis:7-alpine
    command: redis-server --requirepass ${REDIS_PASSWORD}
    volumes:
      - redis_data:/data
    restart: unless-stopped

volumes:
  redis_data:
```

## High Availability

### Redis Sentinel

```bash
REDIS_URL=redis://sentinel1:26379,sentinel2:26379,sentinel3:26379/mymaster
```

### Redis Cluster

```bash
REDIS_URL=redis://node1:6379,node2:6379,node3:6379
```

## Session Storage

With Redis enabled, sessions are stored in Redis instead of PostgreSQL:

```
authority:session:{session_id} -> {user_id, created_at, ...}
```

Session expiry is handled automatically by Redis TTL.

## Token Caching

Access tokens are cached for faster validation:

```
authority:token:{token_hash} -> {user_id, scope, exp, ...}
```

## Rate Limiting

Rate limit counters use Redis:

```
authority:ratelimit:{ip}:{endpoint} -> count
```

## Monitoring

### Redis CLI

```bash
redis-cli

# Check memory usage
INFO memory

# List keys
KEYS authority:*

# Monitor commands
MONITOR
```

### Check Connection

```bash
redis-cli -h localhost -p 6379 ping
```

## Troubleshooting

### Connection refused

Check Redis is running:

```bash
redis-cli ping
```

### Authentication failed

Verify password:

```bash
redis-cli -a your_password ping
```

### Memory full

Check memory usage:

```bash
redis-cli INFO memory
```

Increase maxmemory or use eviction policy.

## Next Steps

- [Environment Variables](environment-variables.md) - All configuration options
- [Docker Installation](../installation/docker.md) - Containerized setup
- [Kubernetes Deployment](../installation/kubernetes.md) - Scalable deployment
