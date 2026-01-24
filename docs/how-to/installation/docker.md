# Docker Installation

Deploy Authority using Docker for production environments.

## Prerequisites

- Docker 20.10+
- Docker Compose 2.0+
- 1GB RAM minimum
- PostgreSQL (included in docker-compose)

## Quick Start

```bash
git clone https://github.com/azutoolkit/authority.git
cd authority
docker-compose up -d
```

Authority is now running at `http://localhost:4000`.

## Production Configuration

### 1. Create Environment File

Create a `.env` file:

```bash
# Server
CRYSTAL_ENV=production
PORT=4000
BASE_URL=https://auth.example.com

# Database
DATABASE_URL=postgres://auth_user:secure_password@db:5432/authority_db

# Security
SECRET_KEY=your-256-bit-secret-key-here

# Token Lifetimes (seconds)
ACCESS_TOKEN_TTL=3600
CODE_TTL=600
DEVICE_CODE_TTL=300

# SSL (optional - use reverse proxy recommended)
SSL_CERT=
SSL_KEY=
```

### 2. Generate Secret Key

```bash
openssl rand -hex 32
```

### 3. Docker Compose File

Create `docker-compose.yml`:

```yaml
version: '3.8'

services:
  authority:
    image: azutoolkit/authority:latest
    ports:
      - "4000:4000"
    environment:
      - CRYSTAL_ENV=production
      - DATABASE_URL=postgres://auth_user:${DB_PASSWORD}@db:5432/authority_db
      - SECRET_KEY=${SECRET_KEY}
      - BASE_URL=${BASE_URL}
    depends_on:
      db:
        condition: service_healthy
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:4000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  db:
    image: postgres:15-alpine
    environment:
      - POSTGRES_USER=auth_user
      - POSTGRES_PASSWORD=${DB_PASSWORD}
      - POSTGRES_DB=authority_db
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U auth_user -d authority_db"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data
    restart: unless-stopped

volumes:
  postgres_data:
  redis_data:
```

### 4. Start Services

```bash
docker-compose up -d
```

## Reverse Proxy Setup

### Nginx Configuration

```nginx
server {
    listen 443 ssl http2;
    server_name auth.example.com;

    ssl_certificate /etc/letsencrypt/live/auth.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/auth.example.com/privkey.pem;

    location / {
        proxy_pass http://localhost:4000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

server {
    listen 80;
    server_name auth.example.com;
    return 301 https://$server_name$request_uri;
}
```

### Traefik Configuration

```yaml
# docker-compose.yml addition
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.authority.rule=Host(`auth.example.com`)"
  - "traefik.http.routers.authority.tls=true"
  - "traefik.http.routers.authority.tls.certresolver=letsencrypt"
```

## Database Migrations

Run migrations manually if needed:

```bash
docker-compose exec authority crystal run src/db/migrate.cr
```

## Backup and Restore

### Backup Database

```bash
docker-compose exec db pg_dump -U auth_user authority_db > backup.sql
```

### Restore Database

```bash
docker-compose exec -T db psql -U auth_user authority_db < backup.sql
```

## Monitoring

### Health Check

```bash
curl http://localhost:4000/health
```

### View Logs

```bash
docker-compose logs -f authority
```

### Resource Usage

```bash
docker stats authority
```

## Scaling

For high availability, run multiple Authority instances behind a load balancer:

```yaml
services:
  authority:
    deploy:
      replicas: 3
```

{% hint style="warning" %}
When running multiple instances, ensure `SECRET_KEY` is identical across all instances and use Redis for session storage.
{% endhint %}

## Troubleshooting

### Container won't start

Check logs:

```bash
docker-compose logs authority
```

### Database connection failed

Verify PostgreSQL is running:

```bash
docker-compose ps db
docker-compose logs db
```

### Port already in use

Change the port:

```bash
PORT=4001 docker-compose up -d
```

## Next Steps

- [Environment Variables](../configuration/environment-variables.md) - All configuration options
- [SSL Certificates](../configuration/ssl-certificates.md) - Enable HTTPS
- [Redis Caching](../configuration/redis-caching.md) - Session storage
