# Architecture

Understanding how Authority is built and organized.

## System Overview

```mermaid
graph TB
    subgraph "Authority Server"
        subgraph "OAuth Endpoints"
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

        subgraph "Security Layer"
            MFA[MFA/TOTP]
            AUDIT[Audit Logging]
            RATE[Rate Limiting]
            LOCKOUT[Account Lockout]
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
```

## Component Architecture

### Endpoints Layer

The endpoints layer handles HTTP requests and responses:

- **OAuth Endpoints** - Authorization, token, introspection, revocation
- **OIDC Endpoints** - UserInfo, discovery, JWKS
- **Admin Endpoints** - Client, user, scope management
- **Auth Endpoints** - Login, logout, password reset

### Services Layer

Business logic is encapsulated in services:

| Service | Responsibility |
|---------|----------------|
| **AuthenticationService** | User authentication, MFA validation |
| **TokenService** | Token generation, validation, revocation |
| **UserService** | User CRUD, password management |
| **ClientService** | OAuth client management |
| **SessionService** | Session creation, validation, cleanup |
| **AuditService** | Event logging, compliance |

### Data Layer

Data access and persistence:

- **Models** - Data structures (User, Client, Token, etc.)
- **Repositories** - Database queries
- **Migrations** - Schema management

## Request Flow

### Authorization Code Flow

```mermaid
sequenceDiagram
    participant Browser
    participant Authority
    participant Database

    Browser->>Authority: GET /authorize
    Authority->>Authority: Validate parameters
    Authority->>Database: Check client exists
    Authority->>Browser: Render login page

    Browser->>Authority: POST /sessions/login
    Authority->>Database: Validate credentials
    Authority->>Database: Check MFA status
    Authority->>Browser: Render consent page

    Browser->>Authority: POST /authorize (consent)
    Authority->>Database: Create authorization code
    Authority->>Browser: Redirect with code

    Browser->>Authority: POST /token
    Authority->>Database: Validate code
    Authority->>Database: Create tokens
    Authority->>Browser: Return tokens
```

### Token Validation Flow

```mermaid
sequenceDiagram
    participant Client
    participant ResourceServer
    participant Authority

    Client->>ResourceServer: Request with access_token
    ResourceServer->>ResourceServer: Validate JWT signature
    ResourceServer->>ResourceServer: Check expiration
    ResourceServer->>ResourceServer: Verify claims

    alt Introspection needed
        ResourceServer->>Authority: POST /token/introspect
        Authority->>ResourceServer: Token status
    end

    ResourceServer->>Client: Protected resource
```

## Data Model

### Core Entities

```mermaid
erDiagram
    USER ||--o{ SESSION : has
    USER ||--o{ ACCESS_TOKEN : owns
    USER ||--o{ AUTHORIZATION_CODE : creates
    CLIENT ||--o{ ACCESS_TOKEN : receives
    CLIENT ||--o{ AUTHORIZATION_CODE : receives
    CLIENT }|--o{ SCOPE : allows
    ACCESS_TOKEN ||--o| REFRESH_TOKEN : paired_with
```

### User

```
users
├── id (UUID)
├── email (unique)
├── password_hash
├── name
├── mfa_secret
├── mfa_enabled
├── locked
├── locked_at
├── failed_attempts
├── role
├── created_at
└── updated_at
```

### Client

```
clients
├── id (UUID)
├── client_id (unique)
├── client_secret_hash
├── name
├── redirect_uris (array)
├── grant_types (array)
├── scopes (array)
├── client_type
├── created_at
└── updated_at
```

## Security Architecture

### Defense in Depth

```
┌─────────────────────────────────────┐
│           Rate Limiting              │
├─────────────────────────────────────┤
│          Input Validation            │
├─────────────────────────────────────┤
│         Authentication               │
├─────────────────────────────────────┤
│         Authorization                │
├─────────────────────────────────────┤
│         Business Logic               │
├─────────────────────────────────────┤
│         Data Validation              │
├─────────────────────────────────────┤
│         Audit Logging                │
└─────────────────────────────────────┘
```

### Token Security

1. **Signing** - JWTs signed with RS256
2. **Rotation** - Refresh tokens rotated on use
3. **Revocation** - Tokens can be invalidated
4. **Expiration** - Short-lived access tokens

## Scalability

### Horizontal Scaling

Authority supports multiple instances:

```
                    ┌─────────────┐
                    │   Load      │
                    │  Balancer   │
                    └──────┬──────┘
            ┌──────────────┼──────────────┐
      ┌─────┴─────┐  ┌─────┴─────┐  ┌─────┴─────┐
      │ Authority │  │ Authority │  │ Authority │
      │ Instance  │  │ Instance  │  │ Instance  │
      └─────┬─────┘  └─────┬─────┘  └─────┬─────┘
            └──────────────┼──────────────┘
                    ┌──────┴──────┐
      ┌─────────────┴─────────────┴─────────────┐
      │              PostgreSQL                   │
      │              (Primary)                    │
      └─────────────┬─────────────┬─────────────┘
                    │             │
              ┌─────┴─────┐ ┌─────┴─────┐
              │  Replica  │ │  Replica  │
              └───────────┘ └───────────┘
```

### Redis for State

Shared state stored in Redis:

- User sessions
- Rate limit counters
- Token cache (optional)

## Technology Stack

| Layer | Technology |
|-------|------------|
| Language | Crystal |
| Web Framework | Azu |
| Database | PostgreSQL |
| Cache | Redis |
| Templates | Crinja (Jinja2) |
| JWT | crystal-jwt |

## Next Steps

- [Security Model](security-model.md) - Security architecture
- [Token Lifecycle](token-lifecycle.md) - Token management
- [OAuth 2.0 Concepts](oauth2-concepts.md) - Protocol fundamentals
