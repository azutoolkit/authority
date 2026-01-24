# Why Authority?

Understanding the benefits and use cases for Authority.

## What is Authority?

Authority is a **production-ready OAuth 2.0 Server and OpenID Connect 1.0 Provider** built with Crystal. It provides:

- Complete OAuth 2.0 implementation
- OpenID Connect identity layer
- Enterprise security features
- Modern admin dashboard
- Self-hosted deployment

## Why Self-Host Authentication?

### Data Sovereignty

Your user data stays on your infrastructure:

- Full control over data location
- Compliance with data residency requirements
- No third-party data access
- Custom retention policies

### Cost Predictability

No per-user or per-authentication pricing:

- Fixed infrastructure costs
- Scale without cost surprises
- No vendor lock-in
- Budget predictability

### Customization

Complete control over the experience:

- Custom login pages
- Branded emails
- Custom flows
- Extended functionality

### Security Control

Your security, your way:

- Configure security policies
- Custom audit requirements
- Integration with existing security tools
- Incident response control

## Key Features

### Complete OAuth 2.0

All standard grant types:

| Grant Type | Use Case |
|------------|----------|
| Authorization Code | Web applications |
| Authorization Code + PKCE | Mobile / SPA |
| Client Credentials | Server-to-server |
| Device Code | IoT / CLI |
| Refresh Token | Token renewal |

### OpenID Connect

Full identity support:

- ID tokens for authentication
- UserInfo endpoint
- Discovery document
- JWKS for verification

### Enterprise Security

Production-ready security:

- Multi-factor authentication (TOTP)
- Account lockout
- Password policies
- Session management
- Comprehensive audit logging
- Rate limiting

### Admin Dashboard

Modern management interface:

- OAuth client management
- User administration
- Scope configuration
- Audit log viewer
- System settings

## Use Cases

### SaaS Applications

Build authentication for your SaaS product:

```
Your App → Authority → User Login → Your App
                    → API Access
```

- Single sign-on across services
- User management
- Third-party integrations

### Internal Tools

Secure internal applications:

- Employee authentication
- Service-to-service auth
- API gateway integration
- Audit compliance

### Developer Platforms

Power developer ecosystems:

- OAuth for third-party apps
- API access control
- Developer portal integration
- Rate limiting per client

### IoT / Device Authentication

Authenticate devices and CLIs:

- Device code flow
- Machine credentials
- Token management

## Comparison

### vs. Auth0 / Okta

| Aspect | Authority | Auth0/Okta |
|--------|-----------|------------|
| Hosting | Self-hosted | Cloud |
| Pricing | Infrastructure only | Per user |
| Data location | Your servers | Their servers |
| Customization | Full | Limited |
| Vendor lock-in | None | High |

### vs. Keycloak

| Aspect | Authority | Keycloak |
|--------|-----------|----------|
| Language | Crystal | Java |
| Memory footprint | Low | High |
| Complexity | Simple | Complex |
| Features | Core OAuth/OIDC | Enterprise IAM |
| Learning curve | Gentle | Steep |

### vs. Build Your Own

| Aspect | Authority | Custom |
|--------|-----------|--------|
| Time to production | Hours | Months |
| Security review | Done | Required |
| Maintenance | Updates | All on you |
| Standards compliance | Complete | Variable |

## Getting Started

### Quick Start

```bash
# Clone and run
git clone https://github.com/azutoolkit/authority.git
cd authority
docker-compose up -d

# Visit http://localhost:4000
```

### Production Deployment

1. Configure environment
2. Set up database
3. Enable HTTPS
4. Create admin user
5. Register clients

See [Installation Guide](../how-to/installation/docker.md).

## Standards Compliance

Authority implements:

- [RFC 6749](https://tools.ietf.org/html/rfc6749) - OAuth 2.0
- [RFC 6750](https://tools.ietf.org/html/rfc6750) - Bearer Tokens
- [RFC 7519](https://tools.ietf.org/html/rfc7519) - JWT
- [RFC 7636](https://tools.ietf.org/html/rfc7636) - PKCE
- [RFC 7662](https://tools.ietf.org/html/rfc7662) - Introspection
- [RFC 7009](https://tools.ietf.org/html/rfc7009) - Revocation
- [RFC 8628](https://tools.ietf.org/html/rfc8628) - Device Authorization
- [OpenID Connect Core 1.0](https://openid.net/specs/openid-connect-core-1_0.html)

## Technology

Built with modern, efficient technology:

| Component | Technology |
|-----------|------------|
| Language | Crystal |
| Framework | Azu |
| Database | PostgreSQL |
| Caching | Redis |
| Templates | Crinja |

Crystal provides:

- **Performance** - Near C speed
- **Safety** - Type-safe, null-safe
- **Simplicity** - Ruby-like syntax
- **Efficiency** - Low memory footprint

## Next Steps

- [Quick Start Tutorial](../tutorials/quick-start.md) - Get running in 5 minutes
- [Architecture](architecture.md) - System design
- [Security Model](security-model.md) - Security features
