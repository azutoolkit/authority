# Social Login API

API endpoints for social authentication (OAuth federation).

## Endpoints Overview

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/auth/{provider}` | Initiate social login |
| GET | `/auth/{provider}/callback` | OAuth callback handler |
| POST | `/auth/{provider}/unlink` | Unlink social account |

## Supported Providers

| Provider | Identifier |
|----------|------------|
| Google | `google` |
| GitHub | `github` |
| Facebook | `facebook` |
| LinkedIn | `linkedin` |
| Apple | `apple` |

---

## Initiate Social Login

Start the OAuth flow with a social provider.

```
GET /auth/{provider}
```

### Path Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `provider` | string | Provider identifier (google, github, etc.) |

### Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `forward_url` | string | No | Base64-encoded URL to redirect after auth |

### Response

Redirects to the provider's authorization page.

### Example

```bash
# Basic social login
curl -I "https://auth.example.com/auth/google"

# With redirect URL
curl -I "https://auth.example.com/auth/google?forward_url=aHR0cHM6Ly9hcHAuZXhhbXBsZS5jb20vZGFzaGJvYXJk"
```

### Errors

| Status | Error | Description |
|--------|-------|-------------|
| 400 | `invalid_provider` | Provider not recognized |
| 400 | `provider_disabled` | Provider not enabled in settings |

---

## OAuth Callback

Handles the callback from the social provider after user authorization.

```
GET /auth/{provider}/callback
```

### Path Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `provider` | string | Provider identifier |

### Query Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `code` | string | Authorization code from provider |
| `state` | string | CSRF protection state parameter |
| `error` | string | Error code if authorization failed |
| `error_description` | string | Human-readable error message |

### Response

On success, redirects to:
- The `forward_url` if provided during initiation
- The default post-login page otherwise

Sets session cookie for authenticated user.

### Errors

| Status | Error | Description |
|--------|-------|-------------|
| 400 | `invalid_state` | State parameter invalid or expired |
| 400 | `authorization_denied` | User denied authorization |
| 400 | `invalid_code` | Authorization code invalid or expired |
| 500 | `provider_error` | Error communicating with provider |

---

## Unlink Social Account

Remove a linked social account from the authenticated user.

```
POST /auth/{provider}/unlink
```

### Path Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `provider` | string | Provider identifier to unlink |

### Authentication

Requires active session (session cookie).

### Response

**Success:** `302` redirect to `/profile` with success flash message.

**Error:** `302` redirect to `/profile` with error flash message.

### Errors

| Status | Error | Description |
|--------|-------|-------------|
| 400 | `invalid_provider` | Provider not recognized |
| 400 | `not_linked` | User doesn't have this provider linked |
| 400 | `cannot_unlink` | Would leave account without login method |
| 401 | `unauthorized` | Not authenticated |

### Example

```bash
curl -X POST "https://auth.example.com/auth/google/unlink" \
  -H "Cookie: session=..." \
  -H "Content-Type: application/json"
```

---

## User Data from Providers

Each provider returns different user information.

### Google

```json
{
  "sub": "google-user-id",
  "email": "user@gmail.com",
  "email_verified": true,
  "name": "John Doe",
  "given_name": "John",
  "family_name": "Doe",
  "picture": "https://lh3.googleusercontent.com/..."
}
```

### GitHub

```json
{
  "id": 12345678,
  "login": "johndoe",
  "email": "john@example.com",
  "name": "John Doe",
  "avatar_url": "https://avatars.githubusercontent.com/..."
}
```

### Facebook

```json
{
  "id": "facebook-user-id",
  "email": "john@example.com",
  "name": "John Doe",
  "picture": {
    "data": {
      "url": "https://graph.facebook.com/..."
    }
  }
}
```

### LinkedIn

```json
{
  "sub": "linkedin-member-id",
  "email": "john@example.com",
  "email_verified": true,
  "name": "John Doe",
  "given_name": "John",
  "family_name": "Doe",
  "picture": "https://media.licdn.com/..."
}
```

### Apple

```json
{
  "sub": "apple-user-id",
  "email": "john@example.com",
  "email_verified": true,
  "name": "John Doe"
}
```

{% hint style="info" %}
Apple only provides the user's name on the first authentication.
{% endhint %}

---

## State Parameter

The state parameter provides CSRF protection:

1. Authority generates a random state value
2. State is stored server-side with expiration
3. State is included in the authorization URL
4. Provider returns the state in the callback
5. Authority validates state matches stored value

State tokens expire after 10 minutes.

---

## Session Handling

After successful authentication:

1. User record created or updated
2. Social connection record created/updated
3. Session created for user
4. Session cookie set in response
5. User redirected to application

Session cookie attributes:
- `HttpOnly`: Yes
- `Secure`: Yes (in production)
- `SameSite`: Lax

---

## Configuration Settings

Social login is configured via settings:

| Setting | Description |
|---------|-------------|
| `GOOGLE_OAUTH_ENABLED` | Enable Google provider |
| `GOOGLE_CLIENT_ID` | Google OAuth client ID |
| `GOOGLE_CLIENT_SECRET` | Google OAuth client secret |
| `GITHUB_OAUTH_ENABLED` | Enable GitHub provider |
| `GITHUB_CLIENT_ID` | GitHub OAuth client ID |
| `GITHUB_CLIENT_SECRET` | GitHub OAuth client secret |
| `FACEBOOK_OAUTH_ENABLED` | Enable Facebook provider |
| `FACEBOOK_CLIENT_ID` | Facebook app ID |
| `FACEBOOK_CLIENT_SECRET` | Facebook app secret |
| `LINKEDIN_OAUTH_ENABLED` | Enable LinkedIn provider |
| `LINKEDIN_CLIENT_ID` | LinkedIn client ID |
| `LINKEDIN_CLIENT_SECRET` | LinkedIn client secret |
| `APPLE_OAUTH_ENABLED` | Enable Apple provider |
| `APPLE_CLIENT_ID` | Apple Services ID |
| `APPLE_TEAM_ID` | Apple Team ID |
| `APPLE_KEY_ID` | Apple Key ID |
| `APPLE_PRIVATE_KEY` | Apple private key (PEM format) |

## Next Steps

- [Configure Google](../../how-to/social-login/configure-google.md) - Setup guide
- [Manage Linked Accounts](../../how-to/social-login/manage-linked-accounts.md) - Account linking
- [Endpoints](endpoints.md) - All API endpoints
