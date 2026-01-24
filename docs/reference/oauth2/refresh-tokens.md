# Refresh Tokens

Refresh tokens allow clients to obtain new access tokens without user interaction.

## Overview

When an access token expires, use the refresh token to get a new one without requiring the user to re-authenticate.

## Token Lifecycle

```mermaid
stateDiagram-v2
    [*] --> Issued: User authorizes
    Issued --> Active: Token valid
    Active --> Expired: TTL exceeded
    Active --> Revoked: User/admin revokes
    Expired --> Refreshed: Use refresh token
    Refreshed --> Active: New access token
    Revoked --> [*]

    note right of Active: Access token usable
    note right of Expired: Access token unusable
    note right of Refreshed: Get new tokens
```

## Token Response

When you receive tokens, note the expiration:

```json
{
  "access_token": "eyJhbGciOiJSUzI1NiIs...",
  "refresh_token": "dGhpcyBpcyBhIHJlZnJlc2g...",
  "token_type": "Bearer",
  "expires_in": 3600
}
```

| Field | Description |
|-------|-------------|
| `access_token` | Short-lived token for API access |
| `refresh_token` | Long-lived token for renewal |
| `expires_in` | Access token lifetime in seconds |

## Refresh Token Request

<mark style="color:green;">`POST`</mark> `/token`

### Headers

| Header | Value |
|--------|-------|
| `Content-Type` | `application/x-www-form-urlencoded` |
| `Authorization` | `Basic {base64(client_id:client_secret)}` |

### Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `grant_type` | Yes | Must be `refresh_token` |
| `refresh_token` | Yes | The refresh token |
| `scope` | Optional | Request subset of original scopes |

### Example

```bash
POST /token HTTP/1.1
Host: auth.example.com
Authorization: Basic YWJjMTIzOnNlY3JldA==
Content-Type: application/x-www-form-urlencoded

grant_type=refresh_token&refresh_token=dGhpcyBpcyBhIHJlZnJlc2g
```

### Response

```json
{
  "access_token": "eyJhbGciOiJSUzI1NiIs...",
  "refresh_token": "bmV3IHJlZnJlc2ggdG9rZW4...",
  "token_type": "Bearer",
  "expires_in": 3600
}
```

{% hint style="info" %}
Authority rotates refresh tokens by default. The old refresh token is invalidated when a new one is issued.
{% endhint %}

## Token Rotation

With rotation enabled, each refresh:

1. Issues a new access token
2. Issues a new refresh token
3. Invalidates the old refresh token

This limits damage if a refresh token is compromised.

## Implementation

### Proactive Refresh

Refresh before expiration:

```javascript
class TokenManager {
  constructor(tokens) {
    this.tokens = tokens;
    this.expiresAt = Date.now() + (tokens.expires_in * 1000);
    this.scheduleRefresh();
  }

  scheduleRefresh() {
    // Refresh 5 minutes before expiry
    const refreshIn = this.expiresAt - Date.now() - (5 * 60 * 1000);

    if (refreshIn > 0) {
      setTimeout(() => this.refresh(), refreshIn);
    }
  }

  async refresh() {
    const response = await fetch('/token', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': `Basic ${btoa(`${CLIENT_ID}:${CLIENT_SECRET}`)}`
      },
      body: new URLSearchParams({
        grant_type: 'refresh_token',
        refresh_token: this.tokens.refresh_token
      })
    });

    this.tokens = await response.json();
    this.expiresAt = Date.now() + (this.tokens.expires_in * 1000);
    this.scheduleRefresh();

    return this.tokens;
  }

  getAccessToken() {
    return this.tokens.access_token;
  }
}
```

### Reactive Refresh

Refresh when access token is rejected:

```javascript
async function apiCall(url, options = {}) {
  let response = await fetch(url, {
    ...options,
    headers: {
      ...options.headers,
      'Authorization': `Bearer ${tokenManager.getAccessToken()}`
    }
  });

  if (response.status === 401) {
    // Token expired, refresh and retry
    await tokenManager.refresh();

    response = await fetch(url, {
      ...options,
      headers: {
        ...options.headers,
        'Authorization': `Bearer ${tokenManager.getAccessToken()}`
      }
    });
  }

  return response;
}
```

## Error Handling

### Invalid Refresh Token

```json
{
  "error": "invalid_grant",
  "error_description": "The refresh token is invalid or expired"
}
```

When this happens, the user must re-authenticate.

### Handling Errors

```javascript
async function refresh() {
  const response = await fetch('/token', {
    method: 'POST',
    // ...
  });

  if (!response.ok) {
    const error = await response.json();

    if (error.error === 'invalid_grant') {
      // Refresh token invalid - require re-login
      logout();
      redirectToLogin();
      return;
    }

    throw new Error(error.error_description);
  }

  return response.json();
}
```

## Scope Reduction

Request fewer scopes when refreshing:

```bash
grant_type=refresh_token
&refresh_token=dGhpcyBpcyBhIHJlZnJlc2g
&scope=read  # Originally had "read write"
```

You cannot request more scopes than originally granted.

## Configuration

### Token Lifetimes

| Variable | Default | Description |
|----------|---------|-------------|
| `ACCESS_TOKEN_TTL` | `3600` | Access token lifetime (seconds) |
| `REFRESH_TOKEN_TTL` | `2592000` | Refresh token lifetime (30 days) |
| `REFRESH_TOKEN_ROTATION` | `true` | Rotate refresh tokens |

### Offline Access

To receive refresh tokens, request the `offline_access` scope:

```bash
scope=openid profile email offline_access
```

## Security Best Practices

{% hint style="success" %}
**Do:**

- Store refresh tokens securely
- Use token rotation
- Refresh proactively before expiry
- Handle refresh failures gracefully
{% endhint %}

{% hint style="warning" %}
**Avoid:**

- Storing refresh tokens in localStorage
- Sharing refresh tokens between tabs
- Ignoring rotation (using old tokens)
- Long refresh token lifetimes without rotation
{% endhint %}

## Revocation

Revoke refresh tokens when:

- User logs out
- User changes password
- Security concern detected

```bash
POST /token/revoke HTTP/1.1
Content-Type: application/x-www-form-urlencoded

token=dGhpcyBpcyBhIHJlZnJlc2g&token_type_hint=refresh_token
```

## Next Steps

- [Token Response](token-response.md) - Response format
- [Error Codes](../api/error-codes.md) - Error handling
- [Token Lifecycle](../../explanation/token-lifecycle.md) - Conceptual overview
