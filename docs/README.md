# Authority

**Production-ready OAuth 2.0 Server and OpenID Connect 1.0 Provider**

Authority is a complete authentication infrastructure built with Crystal, featuring enterprise-grade security and a modern admin dashboard.

## Quick Start

Get Authority running in 5 minutes:

```bash
# Clone the repository
git clone https://github.com/azutoolkit/authority.git
cd authority

# Start with Docker
docker-compose up -d

# Visit http://localhost:4000
```

See [Quick Start Tutorial](tutorials/quick-start.md) for a complete walkthrough.

## Key Features

| Category | Features |
|----------|----------|
| **OAuth 2.0** | Authorization Code, PKCE, Client Credentials, Device Flow, Refresh Tokens |
| **OpenID Connect** | ID Tokens, UserInfo, Discovery, JWKS |
| **Security** | MFA/TOTP, Account Lockout, Password Policies, Audit Logging |
| **Admin** | Client Management, User Management, Scope Configuration, Settings |

## Documentation Overview

This documentation is organized using the [Diataxis framework](https://diataxis.fr/):

### [Tutorials](tutorials/README.md)
Step-by-step guides for learning Authority:
- [Quick Start](tutorials/quick-start.md) - Get running in 5 minutes
- [First OAuth Integration](tutorials/first-oauth-integration.md) - Build your first OAuth app
- [Protect Your API](tutorials/protect-your-api.md) - Secure your endpoints
- [Add User Authentication](tutorials/add-user-authentication.md) - Implement login flows

### [How-To Guides](how-to/installation/docker.md)
Task-oriented guides for specific goals:
- [Installation](how-to/installation/docker.md) - Docker, source, Kubernetes
- [Configuration](how-to/configuration/environment-variables.md) - Environment setup
- [Security](how-to/security/enable-mfa.md) - MFA, lockout, passwords
- [OAuth Clients](how-to/oauth-clients/register-client.md) - Client management

### [Reference](reference/oauth2/README.md)
Technical specifications and API documentation:
- [OAuth 2.0 Flows](reference/oauth2/README.md) - Grant type specifications
- [OpenID Connect](reference/openid-connect/README.md) - OIDC endpoints
- [API Endpoints](reference/api/endpoints.md) - Complete API reference
- [Configuration](reference/configuration/all-options.md) - All settings

### [Explanation](explanation/architecture.md)
Understanding concepts and architecture:
- [Architecture](explanation/architecture.md) - System design
- [OAuth 2.0 Concepts](explanation/oauth2-concepts.md) - Protocol fundamentals
- [Security Model](explanation/security-model.md) - Security architecture
- [Choosing Grant Types](explanation/grant-type-selection.md) - Decision guide

## Standards Compliance

Authority implements these specifications:

- [RFC 6749](https://tools.ietf.org/html/rfc6749) - OAuth 2.0 Authorization Framework
- [RFC 6750](https://tools.ietf.org/html/rfc6750) - Bearer Token Usage
- [RFC 7519](https://tools.ietf.org/html/rfc7519) - JSON Web Token (JWT)
- [RFC 7636](https://tools.ietf.org/html/rfc7636) - Proof Key for Code Exchange (PKCE)
- [RFC 7662](https://tools.ietf.org/html/rfc7662) - Token Introspection
- [RFC 7009](https://tools.ietf.org/html/rfc7009) - Token Revocation
- [RFC 8628](https://tools.ietf.org/html/rfc8628) - Device Authorization Grant
- [OpenID Connect Core 1.0](https://openid.net/specs/openid-connect-core-1_0.html)

## Technology Stack

| Component | Technology |
|-----------|------------|
| Language | Crystal |
| Web Framework | Azu |
| Database | PostgreSQL |
| Templating | Crinja (Jinja2-compatible) |
| Caching | Redis (optional) |

## Screenshots

![Landing Page](screenshots/landing-page.gif)

![Admin Dashboard](screenshots/admin-clients.gif)
