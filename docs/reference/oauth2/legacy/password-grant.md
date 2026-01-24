# Resource Owner Password Grant (Legacy)

{% hint style="warning" %}
**Not Recommended:** The password grant should only be used for first-party, trusted applications. Never allow third-party apps to use this grant.
{% endhint %}

## Overview

The password grant allows applications to exchange user credentials directly for tokens. This bypasses the normal authorization flow.

## When to Use

**Acceptable:**
- First-party mobile apps (owned by same company)
- Migration from legacy systems
- Trusted internal tools

**Never use for:**
- Third-party applications
- Public-facing apps
- Any app you don't fully trust

## Token Request

<mark style="color:green;">`POST`</mark> `/token`

### Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `grant_type` | Yes | Must be `password` |
| `username` | Yes | User's username or email |
| `password` | Yes | User's password |
| `scope` | Optional | Requested scopes |

### Example

```bash
POST /token HTTP/1.1
Host: auth.example.com
Authorization: Basic YWJjMTIzOnNlY3JldA==
Content-Type: application/x-www-form-urlencoded

grant_type=password
&username=user@example.com
&password=secret123
&scope=openid%20profile
```

### Response

```json
{
  "access_token": "eyJhbGciOiJSUzI1NiIs...",
  "token_type": "Bearer",
  "expires_in": 3600,
  "refresh_token": "dGhpcyBpcyBhIHJlZnJlc2g...",
  "scope": "openid profile"
}
```

## Security Risks

1. **Credential exposure** - App sees user's password
2. **No consent** - User doesn't explicitly authorize scopes
3. **Phishing risk** - Encourages entering passwords in apps
4. **MFA bypass** - May skip multi-factor authentication

## Configuration

To enable password grant (not recommended):

```bash
ENABLE_PASSWORD_GRANT=true
PASSWORD_GRANT_ALLOWED_CLIENTS=trusted-app-1,trusted-app-2
```

## Migration Path

Replace password grant with proper OAuth flows:

### Mobile Apps

Use **Authorization Code + PKCE**:

```javascript
// Instead of collecting password in app
// Redirect to Authority's login page
const params = new URLSearchParams({
  response_type: 'code',
  client_id: CLIENT_ID,
  redirect_uri: REDIRECT_URI,
  scope: 'openid profile',
  code_challenge: challenge,
  code_challenge_method: 'S256'
});

// Open in-app browser
openAuthUrl(`${AUTHORITY_URL}/authorize?${params}`);
```

### Web Applications

Use **Authorization Code**:

```javascript
// Redirect to Authority for login
window.location = `${AUTHORITY_URL}/authorize?response_type=code&...`;
```

## Next Steps

- [Authorization Code + PKCE](../authorization-code-pkce.md) - Recommended for mobile/SPA
- [Authorization Code](../authorization-code.md) - Recommended for web apps
- [Client Credentials](../client-credentials.md) - For machine-to-machine
