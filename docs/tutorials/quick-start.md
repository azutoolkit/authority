# Quick Start

Get Authority running in 5 minutes. By the end, you'll have a working OAuth 2.0 server.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) installed
- [Docker Compose](https://docs.docker.com/compose/install/) installed

## Step 1: Clone the Repository

```bash
git clone https://github.com/azutoolkit/authority.git
cd authority
```

## Step 2: Start Authority

```bash
docker-compose up -d
```

This starts:
- Authority server on port 4000
- PostgreSQL database on port 5432

## Step 3: Access the Dashboard

Open your browser to [http://localhost:4000](http://localhost:4000).

You should see the Authority landing page:

![Landing Page](../screenshots/landing-page.gif)

## Step 4: Sign In

Click **Sign In** and use the default admin credentials:

- **Username:** `admin@example.com`
- **Password:** `password123`

![Sign In](../screenshots/signin.gif)

## Step 5: Explore the Admin Dashboard

After signing in, you can:

- **Manage OAuth Clients** - Register applications
- **Manage Users** - Create and edit accounts
- **Configure Scopes** - Define access permissions
- **View Audit Logs** - Track all actions
- **Adjust Settings** - Configure security policies

![Admin Dashboard](../screenshots/admin-clients.gif)

## Step 6: Create Your First OAuth Client

1. Navigate to **OAuth Clients**
2. Click **New Client**
3. Fill in:
   - **Name:** `My Test App`
   - **Redirect URI:** `http://localhost:3000/callback`
4. Click **Create**

You'll receive a `client_id` and `client_secret`. Save these for the next tutorial.

## Next Steps

- [First OAuth Integration](first-oauth-integration.md) - Build a complete OAuth flow
- [Docker Installation Guide](../how-to/installation/docker.md) - Production deployment options
- [Environment Variables](../how-to/configuration/environment-variables.md) - Configuration options

## Troubleshooting

### Port 4000 is in use

Stop the conflicting service or change the port:

```bash
PORT=4001 docker-compose up -d
```

### Database connection failed

Ensure PostgreSQL is running:

```bash
docker-compose logs db
```

### Can't access the dashboard

Check Authority logs:

```bash
docker-compose logs authority
```
