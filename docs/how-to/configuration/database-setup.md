# Database Setup

Configure PostgreSQL for Authority.

## Requirements

- PostgreSQL 13 or higher
- 100MB minimum disk space
- Recommended: SSD storage

## Creating the Database

### Using psql

```bash
# Create database
psql -c "CREATE DATABASE authority_db;"

# Create user (optional)
psql -c "CREATE USER authority WITH PASSWORD 'secure_password';"
psql -c "GRANT ALL PRIVILEGES ON DATABASE authority_db TO authority;"
```

### Using createdb

```bash
createdb authority_db
```

## Connection String

Configure the `DATABASE_URL` environment variable:

```bash
# Basic format
DATABASE_URL=postgres://user:password@host:port/database

# Examples
DATABASE_URL=postgres://localhost:5432/authority_db
DATABASE_URL=postgres://authority:password@localhost:5432/authority_db
```

### SSL Mode

For production, enable SSL:

```bash
DATABASE_URL=postgres://user:password@host:5432/authority_db?sslmode=require
```

SSL modes:
- `disable` - No SSL
- `require` - SSL required, no verification
- `verify-ca` - Verify server certificate
- `verify-full` - Verify server certificate and hostname

## Running Migrations

Migrations create the required tables:

```bash
crystal run src/db/migrate.cr
```

### Tables Created

| Table | Description |
|-------|-------------|
| `users` | User accounts |
| `clients` | OAuth clients |
| `access_tokens` | Access tokens |
| `refresh_tokens` | Refresh tokens |
| `authorization_codes` | Authorization codes |
| `device_codes` | Device authorization codes |
| `scopes` | OAuth scopes |
| `audit_logs` | Audit trail |
| `sessions` | User sessions |

## Seeding Data

Create initial data:

```bash
crystal run src/db/seed.cr
```

This creates:
- Default admin user
- Common OAuth scopes
- System settings

## Backup and Restore

### Backup

```bash
pg_dump -U authority authority_db > backup.sql
```

With compression:

```bash
pg_dump -U authority authority_db | gzip > backup.sql.gz
```

### Restore

```bash
psql -U authority authority_db < backup.sql
```

From compressed:

```bash
gunzip -c backup.sql.gz | psql -U authority authority_db
```

## Connection Pooling

For production, configure connection pooling:

```bash
DATABASE_URL=postgres://user:password@host:5432/authority_db?initial_pool_size=10&max_pool_size=50
```

### Using PgBouncer

```ini
# pgbouncer.ini
[databases]
authority_db = host=localhost port=5432 dbname=authority_db

[pgbouncer]
listen_addr = 127.0.0.1
listen_port = 6432
pool_mode = transaction
max_client_conn = 200
default_pool_size = 20
```

Update connection string:

```bash
DATABASE_URL=postgres://user:password@localhost:6432/authority_db
```

## Performance Tuning

### PostgreSQL Configuration

```ini
# postgresql.conf

# Memory
shared_buffers = 256MB
effective_cache_size = 768MB
work_mem = 16MB

# Connections
max_connections = 100

# Write-ahead log
wal_buffers = 16MB
checkpoint_completion_target = 0.9
```

### Indexes

Authority creates necessary indexes during migration. For additional performance, consider:

```sql
-- Index on frequently queried columns
CREATE INDEX idx_tokens_user_id ON access_tokens(user_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);
```

## Troubleshooting

### Connection refused

Check PostgreSQL is running:

```bash
pg_isready -h localhost -p 5432
```

### Authentication failed

Verify credentials and pg_hba.conf:

```bash
# pg_hba.conf
local   all   all                 trust
host    all   all   127.0.0.1/32  md5
```

### Database does not exist

Create the database:

```bash
createdb authority_db
```

### Permission denied

Grant permissions:

```sql
GRANT ALL PRIVILEGES ON DATABASE authority_db TO authority;
GRANT ALL ON ALL TABLES IN SCHEMA public TO authority;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO authority;
```

## Next Steps

- [Environment Variables](environment-variables.md) - All configuration options
- [Redis Caching](redis-caching.md) - Session storage
- [Docker Installation](../installation/docker.md) - Containerized database
