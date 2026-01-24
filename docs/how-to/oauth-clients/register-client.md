# Register OAuth Client

Create and configure OAuth clients in Authority.

## Overview

OAuth clients represent applications that can request access tokens. Each client has:

- **Client ID** - Public identifier
- **Client Secret** - Confidential key (for confidential clients)
- **Redirect URIs** - Allowed callback URLs
- **Scopes** - Permitted access levels

## Client Types

| Type | Description | Use Case |
|------|-------------|----------|
| **Confidential** | Can securely store secrets | Server-side apps |
| **Public** | Cannot store secrets | Mobile apps, SPAs |

## Admin Dashboard

### Create Client

1. Navigate to **Admin Dashboard** → **OAuth Clients**
2. Click **New Client**
3. Fill in the form:

| Field | Description |
|-------|-------------|
| **Name** | Display name for the client |
| **Type** | Confidential or Public |
| **Redirect URIs** | Callback URLs (one per line) |
| **Scopes** | Allowed scopes |
| **Grant Types** | Enabled OAuth flows |

4. Click **Create**

![OAuth Clients](../../screenshots/admin-clients.gif)

### Client Credentials

After creation, you'll receive:

- **Client ID:** `abc123def456...`
- **Client Secret:** `xyz789ghi012...` (save this - shown only once)

{% hint style="warning" %}
Store the client secret securely. It cannot be retrieved later.
{% endhint %}

## API Registration

### Create Client via API

```bash
POST /register
Content-Type: application/json
Authorization: Bearer {admin_token}

{
  "client_name": "My Application",
  "redirect_uris": [
    "https://myapp.com/callback",
    "https://myapp.com/auth/callback"
  ],
  "grant_types": [
    "authorization_code",
    "refresh_token"
  ],
  "response_types": ["code"],
  "scope": "openid profile email",
  "token_endpoint_auth_method": "client_secret_basic"
}
```

Response:

```json
{
  "client_id": "abc123def456",
  "client_secret": "xyz789ghi012",
  "client_name": "My Application",
  "redirect_uris": [
    "https://myapp.com/callback",
    "https://myapp.com/auth/callback"
  ],
  "grant_types": ["authorization_code", "refresh_token"],
  "response_types": ["code"],
  "scope": "openid profile email",
  "token_endpoint_auth_method": "client_secret_basic",
  "client_id_issued_at": 1705312200,
  "client_secret_expires_at": 0
}
```

### Get Client Details

```bash
GET /register/{client_id}
Authorization: Bearer {admin_token}
```

### Update Client

```bash
PATCH /register/{client_id}
Content-Type: application/json
Authorization: Bearer {admin_token}

{
  "redirect_uris": [
    "https://myapp.com/callback",
    "https://myapp.com/auth/callback",
    "https://staging.myapp.com/callback"
  ]
}
```

### Delete Client

```bash
DELETE /register/{client_id}
Authorization: Bearer {admin_token}
```

## Redirect URI Configuration

### Best Practices

| Do | Don't |
|---|-------|
| Use exact URLs | Use wildcards |
| Use HTTPS in production | Use HTTP in production |
| Register all environments | Use localhost in production |

### Valid Examples

```
https://myapp.com/callback
https://myapp.com/auth/callback
https://staging.myapp.com/callback
http://localhost:3000/callback (development only)
```

### Invalid Examples

```
https://myapp.com/*          # No wildcards
https://*.myapp.com/callback # No wildcards
http://myapp.com/callback    # No HTTP in production
```

## Grant Types

Configure which OAuth flows the client can use:

| Grant Type | Value | Use Case |
|------------|-------|----------|
| Authorization Code | `authorization_code` | Web apps |
| PKCE | `authorization_code` | Mobile/SPA |
| Client Credentials | `client_credentials` | Service-to-service |
| Refresh Token | `refresh_token` | Token renewal |
| Device Code | `urn:ietf:params:oauth:grant-type:device_code` | IoT/CLI |

## Authentication Methods

| Method | Description |
|--------|-------------|
| `client_secret_basic` | HTTP Basic auth |
| `client_secret_post` | Secret in body |
| `none` | Public client (no secret) |

## Scopes

Assign allowed scopes:

```json
{
  "scope": "openid profile email read write admin"
}
```

Clients can only request scopes they're allowed to use.

## Client Metadata

Store additional client information:

```json
{
  "client_name": "My Application",
  "client_uri": "https://myapp.com",
  "logo_uri": "https://myapp.com/logo.png",
  "tos_uri": "https://myapp.com/terms",
  "policy_uri": "https://myapp.com/privacy",
  "contacts": ["support@myapp.com"]
}
```

## Testing Your Client

After registration, test the authorization flow:

```bash
# Open in browser
open "http://localhost:4000/authorize?client_id=YOUR_CLIENT_ID&redirect_uri=YOUR_REDIRECT_URI&response_type=code&scope=openid"
```

## Next Steps

- [Configure Scopes](configure-scopes.md) - Create custom scopes
- [Rotate Secrets](rotate-secrets.md) - Secret management
- [First OAuth Integration](../../tutorials/first-oauth-integration.md) - Complete tutorial
