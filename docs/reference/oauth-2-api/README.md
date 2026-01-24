# OAuth 2 Grant Flows

A grant is a method of acquiring an access token. Deciding which grants to implement depends on the type of client the end-user will be using, and the experience you want for your users.

## Grant Type Selection Guide

```mermaid
flowchart TD
    A[What type of client?] --> B{Server-side app?}
    B -->|Yes| C[Authorization Code]
    B -->|No| D{Mobile/SPA?}
    D -->|Yes| E[Authorization Code + PKCE]
    D -->|No| F{Machine-to-machine?}
    F -->|Yes| G[Client Credentials]
    F -->|No| H{IoT/CLI device?}
    H -->|Yes| I[Device Code]
    H -->|No| J{First-party trusted app?}
    J -->|Yes| K[Resource Owner Password]
    J -->|No| L[Authorization Code + PKCE]

    style C fill:#22c55e,stroke:#16a34a,color:#fff
    style E fill:#22c55e,stroke:#16a34a,color:#fff
    style G fill:#3b82f6,stroke:#2563eb,color:#fff
    style I fill:#8b5cf6,stroke:#7c3aed,color:#fff
    style K fill:#f59e0b,stroke:#d97706,color:#fff
    style L fill:#22c55e,stroke:#16a34a,color:#fff
```

## Available Grant Types

```mermaid
flowchart LR
    subgraph "User-Interactive Flows"
        AC[Authorization Code]
        PKCE[Auth Code + PKCE]
        DC[Device Code]
    end

    subgraph "Non-Interactive Flows"
        CC[Client Credentials]
        RT[Refresh Token]
    end

    subgraph "Legacy Flows"
        IG[Implicit Grant]
        RO[Resource Owner Password]
    end

    style AC fill:#22c55e,stroke:#16a34a,color:#fff
    style PKCE fill:#22c55e,stroke:#16a34a,color:#fff
    style DC fill:#8b5cf6,stroke:#7c3aed,color:#fff
    style CC fill:#3b82f6,stroke:#2563eb,color:#fff
    style RT fill:#3b82f6,stroke:#2563eb,color:#fff
    style IG fill:#6b7280,stroke:#4b5563,color:#fff
    style RO fill:#6b7280,stroke:#4b5563,color:#fff
```

| Grant Type | Use Case | Security Level |
|------------|----------|----------------|
| **Authorization Code** | Web apps with server-side code | High |
| **Authorization Code + PKCE** | Mobile apps, SPAs | High |
| **Client Credentials** | Server-to-server | High |
| **Device Code** | IoT, CLI, Smart TVs | Medium |
| **Refresh Token** | Token renewal | High |
| **Implicit** | Legacy SPAs (deprecated) | Low |
| **Resource Owner Password** | Trusted first-party apps | Medium |

## Quick Reference

### Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/authorize` | GET | Start authorization flow |
| `/token` | POST | Exchange code for tokens |
| `/token/introspect` | POST | Validate a token |
| `/token/revoke` | POST | Revoke a token |
| `/device` | POST | Start device flow |
| `/userinfo` | GET/POST | Get user information |

## Grant Flow Documentation

Dive into the specifics of each OAuth 2 Flow implementation:

{% content-ref url="authorization-flow.md" %}
[authorization-flow.md](authorization-flow.md)
{% endcontent-ref %}

{% content-ref url="device-flow.md" %}
[device-flow.md](device-flow.md)
{% endcontent-ref %}

{% content-ref url="client-credentials.md" %}
[client-credentials.md](client-credentials.md)
{% endcontent-ref %}

{% content-ref url="refreshing-access-tokens.md" %}
[refreshing-access-tokens.md](refreshing-access-tokens.md)
{% endcontent-ref %}

{% content-ref url="access-token-response.md" %}
[access-token-response.md](access-token-response.md)
{% endcontent-ref %}

### Legacy Flows

{% content-ref url="implicit-grant.md" %}
[implicit-grant.md](implicit-grant.md)
{% endcontent-ref %}

{% content-ref url="password.md" %}
[password.md](password.md)
{% endcontent-ref %}
