# Rate Limits

Authority implements rate limiting to protect against abuse.

## Default Limits

| Endpoint | Limit | Window |
|----------|-------|--------|
| `/authorize` | 60 | 1 minute |
| `/token` | 60 | 1 minute |
| `/oauth2/userinfo` | 120 | 1 minute |
| `/register` | 10 | 1 minute |
| `/signin` | 10 | 1 minute |
| `/forgot-password` | 3 | 1 hour |

## Response Headers

Rate limit information is included in response headers:

```
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 45
X-RateLimit-Reset: 1699999999
```

| Header | Description |
|--------|-------------|
| `X-RateLimit-Limit` | Maximum requests in window |
| `X-RateLimit-Remaining` | Requests remaining |
| `X-RateLimit-Reset` | Unix timestamp when limit resets |

## Rate Limit Exceeded

When rate limit is exceeded:

```
HTTP/1.1 429 Too Many Requests
Retry-After: 60
Content-Type: application/json

{
  "error": "rate_limit_exceeded",
  "error_description": "Too many requests. Please retry after 60 seconds.",
  "retry_after": 60
}
```

## Rate Limit Types

### Per IP Address

Default rate limiting is per IP address:

```bash
RATE_LIMIT_BY=ip
```

### Per Client

Rate limit by OAuth client:

```bash
RATE_LIMIT_BY=client
```

### Per User

Rate limit by authenticated user:

```bash
RATE_LIMIT_BY=user
```

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `RATE_LIMIT_ENABLED` | `true` | Enable rate limiting |
| `RATE_LIMIT_BY` | `ip` | Rate limit key |
| `RATE_LIMIT_WINDOW` | `60` | Window in seconds |
| `RATE_LIMIT_MAX` | `60` | Max requests per window |

### Per-Endpoint Configuration

```bash
# Token endpoint: 60 requests per minute
RATE_LIMIT_TOKEN_MAX=60
RATE_LIMIT_TOKEN_WINDOW=60

# Login endpoint: 10 requests per minute
RATE_LIMIT_LOGIN_MAX=10
RATE_LIMIT_LOGIN_WINDOW=60

# Password reset: 3 requests per hour
RATE_LIMIT_PASSWORD_RESET_MAX=3
RATE_LIMIT_PASSWORD_RESET_WINDOW=3600
```

## Whitelist

Exclude IPs from rate limiting:

```bash
RATE_LIMIT_WHITELIST=10.0.0.0/8,192.168.1.0/24
```

## Client-Specific Limits

Configure different limits per client:

```json
{
  "client_id": "trusted-client",
  "rate_limits": {
    "token": {
      "max": 1000,
      "window": 60
    }
  }
}
```

## Best Practices

### Client Implementation

1. **Check headers** - Monitor `X-RateLimit-Remaining`
2. **Implement backoff** - Use exponential backoff on 429
3. **Cache tokens** - Reduce token requests
4. **Batch requests** - Combine when possible

### Handling Rate Limits

```javascript
async function makeRequest(url, options, retries = 3) {
  const response = await fetch(url, options);

  if (response.status === 429) {
    if (retries > 0) {
      const retryAfter = response.headers.get('Retry-After') || 60;
      await sleep(retryAfter * 1000);
      return makeRequest(url, options, retries - 1);
    }
    throw new Error('Rate limit exceeded');
  }

  return response;
}
```

### Monitoring

Monitor rate limit metrics:

- Rate of 429 responses
- Clients hitting limits frequently
- Unusual traffic patterns

## Redis-Based Rate Limiting

For distributed deployments, use Redis:

```bash
RATE_LIMIT_STORE=redis
REDIS_URL=redis://localhost:6379
```

This ensures consistent rate limiting across multiple Authority instances.

## Next Steps

- [API Endpoints](endpoints.md) - Endpoint reference
- [Error Codes](error-codes.md) - Error handling
- [Redis Caching](../../how-to/configuration/redis-caching.md) - Redis setup
