# Install from Source

Build and run Authority from source code.

## Prerequisites

- [Crystal](https://crystal-lang.org/install/) 1.9+
- PostgreSQL 13+
- Git

## Step 1: Clone Repository

```bash
git clone https://github.com/azutoolkit/authority.git
cd authority
```

## Step 2: Install Dependencies

```bash
shards install
```

## Step 3: Set Up Database

Create the database:

```bash
createdb authority_db
```

Or using psql:

```bash
psql -c "CREATE DATABASE authority_db;"
```

## Step 4: Configure Environment

Copy the example environment file:

```bash
cp .env.example .env.local
```

Edit `.env.local`:

```bash
# Server
CRYSTAL_ENV=development
PORT=4000
BASE_URL=http://localhost:4000

# Database
DATABASE_URL=postgres://localhost:5432/authority_db

# Security
SECRET_KEY=development-secret-key-change-in-production

# Token Lifetimes
ACCESS_TOKEN_TTL=3600
CODE_TTL=600
```

## Step 5: Run Migrations

```bash
crystal run src/db/migrate.cr
```

## Step 6: Seed Default Data (Optional)

Create an admin user:

```bash
crystal run src/db/seed.cr
```

## Step 7: Start the Server

Development mode:

```bash
crystal run src/app.cr
```

Or with hot reload:

```bash
./scripts/dev.sh
```

## Production Build

### Compile Release Binary

```bash
crystal build src/app.cr --release -o bin/authority
```

### Run Production Server

```bash
CRYSTAL_ENV=production ./bin/authority
```

## Running Tests

```bash
crystal spec
```

Run specific tests:

```bash
crystal spec spec/models/user_spec.cr
```

## Development Workflow

### Watch for Changes

Use watchexec or similar:

```bash
watchexec -e cr -r "crystal run src/app.cr"
```

### Database Reset

```bash
dropdb authority_db
createdb authority_db
crystal run src/db/migrate.cr
crystal run src/db/seed.cr
```

## File Structure

```
authority/
├── src/
│   ├── app.cr              # Application entry point
│   ├── db/
│   │   ├── migrate.cr      # Migration runner
│   │   ├── seed.cr         # Seed data
│   │   └── migrations/     # Migration files
│   ├── endpoints/          # HTTP handlers
│   ├── models/             # Data models
│   ├── services/           # Business logic
│   └── views/              # Response serializers
├── public/
│   ├── templates/          # Jinja templates
│   ├── css/                # Stylesheets
│   └── js/                 # JavaScript
├── spec/                   # Tests
├── shard.yml               # Dependencies
└── .env.example            # Environment template
```

## Common Issues

### Crystal not found

Ensure Crystal is in your PATH:

```bash
export PATH="$PATH:/usr/local/crystal/bin"
```

### PostgreSQL connection refused

Start PostgreSQL:

```bash
# macOS
brew services start postgresql

# Linux
sudo systemctl start postgresql
```

### Shards install fails

Update shards cache:

```bash
rm -rf lib .shards
shards install
```

### Port already in use

Check what's using the port:

```bash
lsof -i :4000
```

## Next Steps

- [Docker Installation](docker.md) - Containerized deployment
- [Database Setup](../configuration/database-setup.md) - Database configuration
- [Environment Variables](../configuration/environment-variables.md) - All settings
