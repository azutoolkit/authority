<p align="center">
  <img src="https://user-images.githubusercontent.com/1685772/141647649-241cff93-a5dc-4e6a-9695-ff4b9e6a51d4.png" alt="Authority Logo" width="400"/>
</p>

<h1 align="center">Authority</h1>

<p align="center">
  <strong>A Modern OAuth 2.0 Server & OpenID Connect Provider</strong>
</p>

<p align="center">
  Built with Crystal for high performance, low latency, and minimal resource consumption
</p>

<p align="center">
  <a href="https://github.com/azutoolkit/authority/actions/workflows/spec.yml"><img src="https://github.com/azutoolkit/authority/actions/workflows/spec.yml/badge.svg" alt="Test"></a>
  <a href="https://www.codacy.com/gh/azutoolkit/authority/dashboard"><img src="https://app.codacy.com/project/badge/Grade/c19b4551de9f43c2b79664af5908f033" alt="Codacy Badge"></a>
  <img src="https://img.shields.io/github/v/release/azutoolkit/authority?label=version" alt="Release">
  <a href="https://azutopia.gitbook.io/authority"><img src="https://img.shields.io/badge/docs-gitbook-blue" alt="Documentation"></a>
  <img src="https://img.shields.io/badge/license-MIT-green" alt="License">
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#screenshots">Screenshots</a> •
  <a href="#quick-start">Quick Start</a> •
  <a href="#installation">Installation</a> •
  <a href="#configuration">Configuration</a> •
  <a href="#documentation">Documentation</a>
</p>

---

## Why Authority?

Authority is a **production-ready, self-hosted OAuth 2.0 and OpenID Connect server** that gives you complete control over your authentication infrastructure. Unlike cloud-based identity providers, Authority runs on your servers, keeping your user data secure and under your control.

```mermaid
flowchart LR
    subgraph Your Infrastructure
        A[Your App<br/>Client] --> B[Authority<br/>Auth Server]
        B --> C[(User Database)]
    end

    D[End Users] <--> A
    D <--> B

    style B fill:#7c3aed,stroke:#5b21b6,color:#fff
    style A fill:#1e293b,stroke:#334155,color:#fff
    style C fill:#1e293b,stroke:#334155,color:#fff
    style D fill:#3b82f6,stroke:#2563eb,color:#fff
```

### Key Benefits

- **High Performance** - Built with Crystal, achieving exceptional throughput with minimal resource usage
- **Self-Hosted** - Complete control over your authentication infrastructure and user data
- **Standards Compliant** - Full OAuth 2.0 and OpenID Connect 1.0 implementation
- **Beautiful Admin UI** - Modern, dark-themed dashboard for managing users, clients, and settings
- **Enterprise Security** - MFA, audit logging, account lockout, password policies, and more
- **Customizable** - HTML templates powered by Jinja for complete UI customization

### Architecture Overview

```mermaid
graph TB
    subgraph "Authority Server"
        subgraph "Endpoints"
            AUTH["/authorize"]
            TOKEN["/token"]
            INTROSPECT["/introspect"]
            REVOKE["/revoke"]
            DEVICE["/device"]
            USERINFO["/userinfo"]
            JWKS["/.well-known/jwks.json"]
        end

        subgraph "Core Services"
            AS[Authentication Service]
            TS[Token Service]
            US[User Service]
            CS[Client Service]
            SS[Session Service]
        end

        subgraph "Security"
            MFA[MFA/TOTP]
            AUDIT[Audit Logging]
            RATE[Rate Limiting]
        end
    end

    subgraph "Storage"
        PG[(PostgreSQL)]
        REDIS[(Redis Cache)]
    end

    AUTH --> AS
    TOKEN --> TS
    AS --> US
    TS --> CS
    US --> PG
    CS --> PG
    SS --> REDIS
    AUDIT --> PG

    style AUTH fill:#7c3aed,stroke:#5b21b6,color:#fff
    style TOKEN fill:#7c3aed,stroke:#5b21b6,color:#fff
    style PG fill:#336791,stroke:#264d73,color:#fff
    style REDIS fill:#dc382d,stroke:#a32b23,color:#fff
```

---

## Features

### OAuth 2.0 Grant Types

| Grant Type | Use Case |
|------------|----------|
| **Authorization Code** | Web applications with server-side code |
| **Authorization Code + PKCE** | Mobile and single-page applications |
| **Client Credentials** | Machine-to-machine authentication |
| **Resource Owner Password** | Trusted first-party applications |
| **Implicit** | Legacy browser-based applications |
| **Device Code** | IoT devices, CLIs, and smart TVs |
| **Refresh Token** | Long-lived access with token rotation |

### Security Features

- **Multi-Factor Authentication (MFA)** - TOTP-based 2FA with backup codes
- **Account Lockout** - Configurable thresholds with progressive delays
- **Password Policies** - Minimum length, history, and expiry requirements
- **Session Management** - Persistent sessions with device tracking
- **Audit Logging** - Comprehensive action tracking with export capabilities
- **Token Rotation** - Automatic refresh token rotation for enhanced security
- **PKCE Support** - Proof Key for Code Exchange for public clients

### Admin Dashboard

- **User Management** - Create, edit, lock/unlock accounts, manage roles
- **Client Management** - Register OAuth clients, manage secrets and scopes
- **Scope Management** - Define and manage permission scopes
- **Audit Logs** - View, filter, and export security audit logs
- **System Settings** - Configure security, email, and branding options

### Standards Compliance

- [RFC 6749](https://tools.ietf.org/html/rfc6749) - OAuth 2.0 Authorization Framework
- [RFC 6750](https://tools.ietf.org/html/rfc6750) - Bearer Token Usage
- [RFC 7519](https://tools.ietf.org/html/rfc7519) - JSON Web Token (JWT)
- [RFC 7636](https://tools.ietf.org/html/rfc7636) - PKCE for OAuth Public Clients
- [RFC 7662](https://tools.ietf.org/html/rfc7662) - Token Introspection
- [RFC 7009](https://tools.ietf.org/html/rfc7009) - Token Revocation
- [RFC 8628](https://tools.ietf.org/html/rfc8628) - Device Authorization Grant
- [OpenID Connect Core 1.0](https://openid.net/specs/openid-connect-core-1_0.html)

---

## Screenshots

### Landing Page

![Landing Page](./docs/screenshots/landing-page.gif)

### Sign In

![Sign In](./docs/screenshots/signin.gif)

---

## Admin Dashboard

Authority includes a powerful, modern admin dashboard with a beautiful dark theme for managing your OAuth infrastructure.

### OAuth Clients Management

![OAuth Clients](./docs/screenshots/admin-clients.gif)

Register and manage OAuth applications with redirect URIs, client secrets, and scope assignments.

### User Management

![User Management](./docs/screenshots/admin-users.gif)

Create, edit, lock/unlock accounts, assign admin/user roles, and manage passwords.

### Scope Management

![Scope Management](./docs/screenshots/admin-scopes.gif)

Define system and custom OAuth scopes with descriptions.

### Audit Logs

![Audit Logs](./docs/screenshots/admin-audit-logs.gif)

Track all administrative actions with filtering by actor, action type, and date range. Export to CSV.

### System Settings

![System Settings](./docs/screenshots/admin-settings.gif)

Configure account lockout, password policies, session duration, email, and branding.

### User Profile

![User Profile](./docs/screenshots/user-profile.gif)

Self-service profile management, MFA setup, password changes, and active sessions

---

### OAuth 2.0 Grant Flows

```mermaid
flowchart TB
    subgraph "Authorization Code Flow"
        A1[User] -->|1. Login Request| B1[Client App]
        B1 -->|2. Redirect to /authorize| C1[Authority]
        C1 -->|3. User Authentication| A1
        A1 -->|4. Grant Permission| C1
        C1 -->|5. Authorization Code| B1
        B1 -->|6. Exchange Code for Token| C1
        C1 -->|7. Access Token + Refresh Token| B1
    end

    subgraph "Client Credentials Flow"
        B2[Service/API] -->|1. Client ID + Secret| C2[Authority]
        C2 -->|2. Access Token| B2
    end

    subgraph "Device Code Flow"
        D1[Device/CLI] -->|1. Request Device Code| C3[Authority]
        C3 -->|2. Device Code + User Code| D1
        D1 -->|3. Display Code to User| A2[User]
        A2 -->|4. Enter Code at /device| C3
        A2 -->|5. Authorize| C3
        D1 -->|6. Poll for Token| C3
        C3 -->|7. Access Token| D1
    end

    style C1 fill:#7c3aed,stroke:#5b21b6,color:#fff
    style C2 fill:#7c3aed,stroke:#5b21b6,color:#fff
    style C3 fill:#7c3aed,stroke:#5b21b6,color:#fff
```

---

## Quick Start

### Using Docker (Recommended)

```bash
# Clone the repository
git clone https://github.com/azutoolkit/authority.git
cd authority

# Start with Docker Compose
docker-compose up -d

# Authority is now running at http://localhost:4000
```

### Client Credentials Flow Example

```bash
# Get an access token
curl -X POST http://localhost:4000/token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=client_credentials" \
  -d "client_id=YOUR_CLIENT_ID" \
  -d "client_secret=YOUR_CLIENT_SECRET" \
  -d "scope=read write"
```

### Authorization Code Flow Example

```mermaid
sequenceDiagram
    participant U as User
    participant C as Client App
    participant A as Authority

    U->>C: 1. Click "Login"
    C->>A: 2. Redirect to /authorize
    A->>U: 3. Show login form
    U->>A: 4. Enter credentials
    A->>U: 5. Show consent screen
    U->>A: 6. Approve scopes
    A->>C: 7. Redirect with auth code
    C->>A: 8. POST /token (exchange code)
    A->>C: 9. Access token + Refresh token
    C->>U: 10. User logged in!
```

```bash
# Step 1: Redirect user to authorization endpoint
https://localhost:4000/authorize?
  response_type=code&
  client_id=YOUR_CLIENT_ID&
  redirect_uri=https://yourapp.com/callback&
  scope=openid profile email&
  state=random_state_string

# Step 2: Exchange code for tokens
curl -X POST http://localhost:4000/token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=authorization_code" \
  -d "code=AUTHORIZATION_CODE" \
  -d "client_id=YOUR_CLIENT_ID" \
  -d "client_secret=YOUR_CLIENT_SECRET" \
  -d "redirect_uri=https://yourapp.com/callback"
```

---

## Installation

### Prerequisites

- [Crystal](https://crystal-lang.org/install/) 1.9+
- PostgreSQL 13+
- Redis (optional, for caching)

### From Source

```bash
# Clone the repository
git clone https://github.com/azutoolkit/authority.git
cd authority

# Install dependencies
shards install

# Setup database
createdb authority_development
crystal run src/db/migrate.cr

# Run the server
crystal run src/server.cr
```

### Using Docker

```dockerfile
FROM ghcr.io/azutoolkit/authority:latest

ENV DATABASE_URL=postgres://user:pass@host:5432/authority
ENV SECRET_KEY_BASE=your-secret-key

EXPOSE 4000
CMD ["./authority"]
```

---

## Configuration

Authority is configured via environment variables:

### Database

```bash
DATABASE_URL=postgres://localhost:5432/authority
```

### Security

```bash
SECRET_KEY_BASE=your-256-bit-secret-key
ACCESS_TOKEN_TTL=3600        # 1 hour
REFRESH_TOKEN_TTL=2592000    # 30 days
AUTH_CODE_TTL=600            # 10 minutes
```

### Account Security

```bash
LOCKOUT_THRESHOLD=5          # Failed attempts before lockout
LOCKOUT_DURATION=30          # Minutes
PASSWORD_MIN_LENGTH=12
PASSWORD_HISTORY_COUNT=5
SESSION_DURATION_DAYS=7
```

### Email (SMTP)

```bash
SMTP_HOST=smtp.example.com
SMTP_PORT=587
SMTP_USERNAME=your-username
SMTP_PASSWORD=your-password
SMTP_FROM=noreply@example.com
```

See the [Configuration Guide](https://azutopia.gitbook.io/authority/configuration) for all options.

---

## API Endpoints

### OAuth 2.0

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/authorize` | GET | Authorization endpoint |
| `/token` | POST | Token endpoint |
| `/token/introspect` | POST | Token introspection |
| `/token/revoke` | POST | Token revocation |
| `/device` | POST | Device authorization |
| `/.well-known/jwks.json` | GET | JSON Web Key Set |

### OpenID Connect

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/.well-known/openid-configuration` | GET | Discovery document |
| `/userinfo` | GET/POST | User info endpoint |

### User Management

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/signin` | GET/POST | User sign in |
| `/signup` | GET/POST | User registration |
| `/profile` | GET/POST | User profile |
| `/password/reset` | POST | Password reset |

---

## Documentation

Comprehensive documentation is available at:

[![Documentation](https://img.shields.io/badge/Read%20the%20Docs-Authority-blue?style=for-the-badge)](https://azutopia.gitbook.io/authority)

### Topics Covered

- [Getting Started](https://azutopia.gitbook.io/authority/installation)
- [Configuration Guide](https://azutopia.gitbook.io/authority/configuration)
- [OAuth 2.0 Flows](https://azutopia.gitbook.io/authority/reference/oauth-2-api)
- [OpenID Connect](https://azutopia.gitbook.io/authority/reference/open-id-connect)
- [Security Best Practices](https://azutopia.gitbook.io/authority/security)
- [API Reference](https://azutopia.gitbook.io/authority/api-endpoints)
- [Customization](https://azutopia.gitbook.io/authority/customizing-authentication)

---

## Technology Stack

| Component | Technology |
|-----------|------------|
| Language | [Crystal](https://crystal-lang.org/) |
| Web Framework | [Azu](https://github.com/azutoolkit/azu) |
| Database | PostgreSQL |
| Templating | Crinja (Jinja2-compatible) |
| Authentication | Authly |
| JWT | crystal-jwt |
| Caching | Redis (optional) |

---

## Performance

Authority is designed for high-performance scenarios:

- **Low Latency** - Crystal's compiled nature ensures fast response times
- **Minimal Memory** - Efficient memory usage compared to interpreted languages
- **High Throughput** - Handles thousands of requests per second
- **Scalable** - Stateless design allows horizontal scaling

---

## Contributing

We welcome contributions! Here's how to get started:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Write tests for your changes
4. Commit your changes (`git commit -m 'Add amazing feature'`)
5. Push to the branch (`git push origin feature/amazing-feature`)
6. Open a Pull Request

### Development Setup

```bash
# Install dependencies
shards install

# Run tests
crystal spec

# Run linter
./bin/ameba

# Start development server
crystal run src/server.cr
```

---

## License

Authority is released under the [MIT License](LICENSE).

---

## Support

- **Documentation**: [azutopia.gitbook.io/authority](https://azutopia.gitbook.io/authority)
- **Issues**: [GitHub Issues](https://github.com/azutoolkit/authority/issues)
- **Discussions**: [GitHub Discussions](https://github.com/azutoolkit/authority/discussions)

---

<p align="center">
  Made with Crystal by <a href="https://github.com/eliasjpr">Elias Perez</a>
</p>
