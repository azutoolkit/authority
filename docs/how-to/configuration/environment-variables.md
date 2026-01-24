# Environment Variables

Configure Authority using environment variables.

## Server Settings

| Variable | Default | Description |
|----------|---------|-------------|
| `CRYSTAL_ENV` | `development` | Environment: `development`, `production`, `test` |
| `PORT` | `4000` | HTTP server port |
| `HOST` | `0.0.0.0` | Bind address |
| `BASE_URL` | `http://localhost:4000` | Public URL for redirects and links |
| `CRYSTAL_WORKERS` | `4` | Number of worker processes |

## Database

| Variable | Default | Description |
|----------|---------|-------------|
| `DATABASE_URL` | Required | PostgreSQL connection string |

Example connection strings:

```bash
# Local development
DATABASE_URL=postgres://localhost:5432/authority_db

# With credentials
DATABASE_URL=postgres://user:password@localhost:5432/authority_db

# With SSL
DATABASE_URL=postgres://user:password@host:5432/authority_db?sslmode=require
```

## Security

| Variable | Default | Description |
|----------|---------|-------------|
| `SECRET_KEY` | Required | JWT signing key (256-bit minimum) |

Generate a secure key:

```bash
openssl rand -hex 32
```

## Token Lifetimes

| Variable | Default | Description |
|----------|---------|-------------|
| `ACCESS_TOKEN_TTL` | `3600` | Access token lifetime (seconds) |
| `CODE_TTL` | `600` | Authorization code lifetime (seconds) |
| `DEVICE_CODE_TTL` | `300` | Device code lifetime (seconds) |

## Session

| Variable | Default | Description |
|----------|---------|-------------|
| `SESSION_KEY` | `session_id` | Session cookie name |
| `SESSION_DURATION_DAYS` | `7` | Session lifetime (days) |

## SSL/TLS

| Variable | Default | Description |
|----------|---------|-------------|
| `SSL_CERT` | | Path to SSL certificate |
| `SSL_KEY` | | Path to SSL private key |
| `SSL_CA` | | Path to CA certificate |
| `SSL_MODE` | | SSL mode: `require`, `verify-ca`, `verify-full` |

## Templates

| Variable | Default | Description |
|----------|---------|-------------|
| `TEMPLATES_PATH` | `./public/templates` | Path to Jinja templates |

## Logging

| Variable | Default | Description |
|----------|---------|-------------|
| `CRYSTAL_LOG_LEVEL` | `debug` | Log level: `debug`, `info`, `warn`, `error` |
| `CRYSTAL_LOG_SOURCES` | `*` | Log sources filter |

## Example Configuration

### Development

```bash
# .env.local
CRYSTAL_ENV=development
PORT=4000
BASE_URL=http://localhost:4000
DATABASE_URL=postgres://localhost:5432/authority_db
SECRET_KEY=development-key-not-for-production
CRYSTAL_LOG_LEVEL=debug
```

### Production

```bash
# .env
CRYSTAL_ENV=production
PORT=4000
HOST=0.0.0.0
BASE_URL=https://auth.example.com
DATABASE_URL=postgres://user:password@db.example.com:5432/authority_db?sslmode=require
SECRET_KEY=your-256-bit-production-secret-key
ACCESS_TOKEN_TTL=3600
SESSION_DURATION_DAYS=7
CRYSTAL_LOG_LEVEL=info
CRYSTAL_WORKERS=8
```

## Loading Environment Variables

### From File

Authority automatically loads `.env.local` in development:

```bash
crystal run src/app.cr
```

### From Shell

```bash
export DATABASE_URL=postgres://localhost:5432/authority_db
crystal run src/app.cr
```

### Docker

```bash
docker run -e DATABASE_URL=... -e SECRET_KEY=... azutoolkit/authority
```

Or with env file:

```bash
docker run --env-file .env azutoolkit/authority
```

## Next Steps

- [Database Setup](database-setup.md) - Database configuration
- [Redis Caching](redis-caching.md) - Session storage
- [SSL Certificates](ssl-certificates.md) - HTTPS setup
