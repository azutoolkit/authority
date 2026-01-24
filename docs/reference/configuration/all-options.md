# All Configuration Options

Complete reference for all Authority configuration options.

## Server

| Variable | Default | Description |
|----------|---------|-------------|
| `CRYSTAL_ENV` | `development` | Environment: `development`, `production`, `test` |
| `PORT` | `4000` | HTTP server port |
| `HOST` | `0.0.0.0` | Bind address |
| `BASE_URL` | `http://localhost:4000` | Public URL |
| `CRYSTAL_WORKERS` | `4` | Worker processes |

## Database

| Variable | Default | Description |
|----------|---------|-------------|
| `DATABASE_URL` | Required | PostgreSQL connection string |

## Security

| Variable | Default | Description |
|----------|---------|-------------|
| `SECRET_KEY` | Required | JWT signing key (256-bit) |

See [Security Settings](security-settings.md) for security-specific options.

## Tokens

| Variable | Default | Description |
|----------|---------|-------------|
| `ACCESS_TOKEN_TTL` | `3600` | Access token lifetime (seconds) |
| `CODE_TTL` | `600` | Authorization code lifetime (seconds) |
| `DEVICE_CODE_TTL` | `300` | Device code lifetime (seconds) |

See [Token Settings](token-settings.md) for token-specific options.

## Sessions

| Variable | Default | Description |
|----------|---------|-------------|
| `SESSION_KEY` | `session_id` | Session cookie name |
| `SESSION_DURATION_DAYS` | `7` | Session lifetime (days) |
| `IDLE_TIMEOUT_MINUTES` | `30` | Idle timeout |
| `SINGLE_SESSION` | `false` | Allow only one session |

## SSL/TLS

| Variable | Default | Description |
|----------|---------|-------------|
| `SSL_CERT` | | Path to certificate |
| `SSL_KEY` | | Path to private key |
| `SSL_CA` | | Path to CA certificate |
| `SSL_MODE` | | SSL mode |

## Templates

| Variable | Default | Description |
|----------|---------|-------------|
| `TEMPLATES_PATH` | `./public/templates` | Template directory |

## Logging

| Variable | Default | Description |
|----------|---------|-------------|
| `CRYSTAL_LOG_LEVEL` | `debug` | Log level |
| `CRYSTAL_LOG_SOURCES` | `*` | Log sources |

## Email

| Variable | Default | Description |
|----------|---------|-------------|
| `SMTP_HOST` | | SMTP server host |
| `SMTP_PORT` | `587` | SMTP server port |
| `SMTP_USER` | | SMTP username |
| `SMTP_PASSWORD` | | SMTP password |
| `SMTP_FROM` | | Sender email |
| `SMTP_FROM_NAME` | `Authority` | Sender name |

## Redis

| Variable | Default | Description |
|----------|---------|-------------|
| `REDIS_URL` | | Redis connection URL |

## Rate Limiting

| Variable | Default | Description |
|----------|---------|-------------|
| `RATE_LIMIT_ENABLED` | `true` | Enable rate limiting |
| `RATE_LIMIT_BY` | `ip` | Rate limit key |
| `RATE_LIMIT_WINDOW` | `60` | Window (seconds) |
| `RATE_LIMIT_MAX` | `60` | Max requests |
| `RATE_LIMIT_WHITELIST` | | Exempt IPs |

## Branding

| Variable | Default | Description |
|----------|---------|-------------|
| `APP_NAME` | `Authority` | Application name |
| `APP_TAGLINE` | | Application tagline |
| `COMPANY_NAME` | | Company name |
| `THEME` | `dark` | Theme (dark/light) |

## OAuth

| Variable | Default | Description |
|----------|---------|-------------|
| `ENABLE_PASSWORD_GRANT` | `false` | Enable password grant |
| `PASSWORD_GRANT_ALLOWED_CLIENTS` | | Allowed client IDs |
| `DEFAULT_SCOPES` | `openid` | Default scopes |

## Example Configuration

### Development

```bash
CRYSTAL_ENV=development
PORT=4000
BASE_URL=http://localhost:4000
DATABASE_URL=postgres://localhost:5432/authority_db
SECRET_KEY=dev-secret-key
CRYSTAL_LOG_LEVEL=debug
```

### Production

```bash
CRYSTAL_ENV=production
PORT=4000
BASE_URL=https://auth.example.com
DATABASE_URL=postgres://user:pass@db:5432/authority_db?sslmode=require
SECRET_KEY=your-production-secret-key
CRYSTAL_WORKERS=8
CRYSTAL_LOG_LEVEL=info

# Security
LOCKOUT_THRESHOLD=5
LOCKOUT_DURATION=30
PASSWORD_MIN_LENGTH=12
REQUIRE_ADMIN_MFA=true

# Tokens
ACCESS_TOKEN_TTL=3600
REFRESH_TOKEN_TTL=2592000

# Redis
REDIS_URL=redis://redis:6379

# Email
SMTP_HOST=smtp.example.com
SMTP_PORT=587
SMTP_USER=noreply@example.com
SMTP_PASSWORD=your-smtp-password
SMTP_FROM=noreply@example.com
```

## Next Steps

- [Security Settings](security-settings.md) - Security configuration
- [Token Settings](token-settings.md) - Token configuration
- [Environment Variables](../../how-to/configuration/environment-variables.md) - Setup guide
