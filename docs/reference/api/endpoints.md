# API Endpoints

Complete reference for all Authority API endpoints.

## OAuth 2.0 Endpoints

### Authorization Endpoint

<mark style="color:blue;">`GET`</mark> `/authorize`

Initiates the OAuth 2.0 authorization flow. Displays consent form to user.

**Query Parameters:**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `response_type` | Yes | Must be `code` |
| `client_id` | Yes | The client identifier |
| `redirect_uri` | Yes | Callback URL (must match registered URI) |
| `scope` | Yes | Space-separated scopes |
| `state` | Yes | CSRF protection token |
| `code_challenge` | For PKCE | Base64URL-encoded challenge |
| `code_challenge_method` | For PKCE | `S256` or `plain` |
| `nonce` | For OIDC | Replay prevention token |

**Example:**

```bash
GET /authorize?response_type=code&client_id=abc123&redirect_uri=https://app.example.com/callback&scope=openid%20profile&state=xyz789
```

**Response:** Redirects to login page, then to `redirect_uri` with `code` and `state` parameters.

**Error Response:** Redirects to `redirect_uri` with `error`, `error_description`, and `state` parameters.

---

<mark style="color:green;">`POST`</mark> `/authorize`

Process user consent for authorization request.

**Request Body (Form-encoded):**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `response_type` | Yes | Must be `code` |
| `client_id` | Yes | The client identifier |
| `redirect_uri` | Yes | Callback URL |
| `scope` | Yes | Space-separated scopes |
| `state` | Yes | CSRF protection token |
| `consent_action` | Yes | `approve` or `deny` |
| `code_challenge` | For PKCE | Base64URL-encoded challenge |
| `code_challenge_method` | For PKCE | `S256` or `plain` |
| `nonce` | For OIDC | Replay prevention token |

**Response:** `302` redirect to `redirect_uri?code=<code>&state=<state>`

---

### Token Endpoint

<mark style="color:green;">`POST`</mark> `/token`

Exchange authorization code, refresh token, or client credentials for access tokens.

**Headers:**

| Header | Description |
|--------|-------------|
| `Content-Type` | `application/x-www-form-urlencoded` |
| `Authorization` | `Basic {base64(client_id:client_secret)}` |

**Request Body (Authorization Code):**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `grant_type` | Yes | `authorization_code` |
| `code` | Yes | Authorization code |
| `redirect_uri` | Yes | Same as authorization request |
| `code_verifier` | For PKCE | Original code verifier |

**Request Body (Refresh Token):**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `grant_type` | Yes | `refresh_token` |
| `refresh_token` | Yes | Refresh token |

**Request Body (Client Credentials):**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `grant_type` | Yes | `client_credentials` |
| `scope` | Optional | Requested scopes |

**Request Body (Password Grant - Legacy):**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `grant_type` | Yes | `password` |
| `username` | Yes | User's email |
| `password` | Yes | User's password |
| `scope` | Optional | Requested scopes |

**Response:** `201 Created`

```json
{
  "access_token": "eyJhbGciOiJSUzI1NiIs...",
  "token_type": "Bearer",
  "expires_in": 3600,
  "refresh_token": "dGhpcyBpcyBhIHJlZnJlc2g...",
  "scope": "openid profile email"
}
```

---

### Token Introspection

<mark style="color:green;">`POST`</mark> `/oauth/introspect`

Validate a token and get its metadata (RFC 7662).

**Headers:**

| Header | Description |
|--------|-------------|
| `Content-Type` | `application/x-www-form-urlencoded` |
| `Authorization` | `Basic {base64(client_id:client_secret)}` |

**Request Body:**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `token` | Yes | Token to introspect |
| `token_type_hint` | Optional | `access_token` or `refresh_token` |

**Response (Active Token):** `200 OK`

```json
{
  "active": true,
  "client_id": "abc123",
  "username": "user@example.com",
  "scope": "openid profile email",
  "sub": "user-uuid",
  "token_type": "Bearer",
  "exp": 1699999999,
  "iat": 1699996399
}
```

**Response (Inactive Token):**

```json
{
  "active": false
}
```

---

### Token Revocation

<mark style="color:green;">`POST`</mark> `/oauth/revoke`

Revoke an access or refresh token (RFC 7009).

**Headers:**

| Header | Description |
|--------|-------------|
| `Content-Type` | `application/x-www-form-urlencoded` |
| `Authorization` | `Basic {base64(client_id:client_secret)}` |

**Request Body:**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `token` | Yes | Token to revoke |
| `token_type_hint` | Optional | `access_token` or `refresh_token` |

**Response:** `200 OK` (always succeeds per RFC 7009)

---

### Device Authorization

<mark style="color:green;">`POST`</mark> `/device/code`

Start device authorization flow (RFC 8628).

**Headers:**

| Header | Description |
|--------|-------------|
| `Content-Type` | `application/x-www-form-urlencoded` |

**Request Body:**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `client_id` | Yes | Client identifier |

**Response:** `201 Created`

```json
{
  "device_code": "e2623df1-8594-47b4-b528-41ed3daecc1a",
  "user_code": "56933A",
  "verification_uri": "https://auth.example.com/activate",
  "verification_uri_complete": "https://auth.example.com/activate?user_code=56933A",
  "audience": "My Application",
  "expires_in": 300,
  "interval": 5
}
```

---

### Device Token Polling

<mark style="color:green;">`POST`</mark> `/device/token`

Poll for device authorization completion.

**Request Body:**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `grant_type` | Yes | `urn:ietf:params:oauth:grant-type:device_code` |
| `client_id` | Yes | Client identifier |
| `code` | Yes | Device code from `/device/code` |

**Response (Pending):** `400 Bad Request`

```json
{
  "error": "authorization_pending",
  "error_description": "The user has not yet completed authorization"
}
```

**Response (Success):** `201 Created`

```json
{
  "access_token": "eyJhbGciOiJSUzI1NiIs...",
  "token_type": "Bearer",
  "expires_in": 3600,
  "refresh_token": "...",
  "scope": "openid profile"
}
```

---

### Device Activation

<mark style="color:blue;">`GET`</mark> `/activate`

Display device activation form for user to enter code.

**Query Parameters:**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `user_code` | Optional | Pre-fill user code |

**Response:** HTML form for user to enter device code.

---

<mark style="color:green;">`POST`</mark> `/activate`

Process device activation.

**Request Body:**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `user_code` | Yes | User code from device |

**Response:** HTML confirmation page.

---

## OpenID Connect Endpoints

### UserInfo

<mark style="color:blue;">`GET`</mark> `/oauth2/userinfo`

Get authenticated user's claims.

**Headers:**

| Header | Description |
|--------|-------------|
| `Authorization` | `Bearer {access_token}` |

**Response:** `200 OK`

```json
{
  "sub": "user-uuid",
  "name": "John Doe",
  "given_name": "John",
  "family_name": "Doe",
  "email": "john@example.com",
  "email_verified": true
}
```

---

### Discovery

<mark style="color:blue;">`GET`</mark> `/.well-known/openid-configuration`

OpenID Connect discovery document.

**Response:** `200 OK`

```json
{
  "issuer": "https://auth.example.com",
  "authorization_endpoint": "https://auth.example.com/authorize",
  "token_endpoint": "https://auth.example.com/token",
  "userinfo_endpoint": "https://auth.example.com/oauth2/userinfo",
  "jwks_uri": "https://auth.example.com/.well-known/jwks.json",
  "introspection_endpoint": "https://auth.example.com/oauth/introspect",
  "revocation_endpoint": "https://auth.example.com/oauth/revoke",
  "device_authorization_endpoint": "https://auth.example.com/device/code",
  "scopes_supported": ["openid", "profile", "email", "read", "write"],
  "response_types_supported": ["code", "token"],
  "grant_types_supported": [
    "authorization_code",
    "client_credentials",
    "password",
    "refresh_token",
    "urn:ietf:params:oauth:grant-type:device_code"
  ],
  "subject_types_supported": ["public"],
  "id_token_signing_alg_values_supported": ["RS256"],
  "code_challenge_methods_supported": ["S256", "plain"],
  "claims_supported": [
    "sub", "iss", "aud", "exp", "iat",
    "email", "email_verified", "name",
    "given_name", "family_name"
  ]
}
```

**Caching:** `public, max-age=3600`

---

### JWKS

<mark style="color:blue;">`GET`</mark> `/.well-known/jwks.json`

JSON Web Key Set for token verification.

**Response:** `200 OK`

```json
{
  "keys": [
    {
      "kty": "RSA",
      "kid": "authority-key-1",
      "use": "sig",
      "alg": "RS256",
      "n": "...",
      "e": "AQAB"
    }
  ]
}
```

**Caching:** `public, max-age=3600`

---

## Dynamic Client Registration

### Register Client

<mark style="color:green;">`POST`</mark> `/register`

Dynamically register an OAuth client (RFC 7591).

**Request Body:**

```json
{
  "client_name": "My Application",
  "redirect_uris": ["https://app.example.com/callback"],
  "grant_types": ["authorization_code", "refresh_token"],
  "response_types": ["code"],
  "token_endpoint_auth_method": "client_secret_basic",
  "scope": "openid profile email",
  "logo_uri": "https://app.example.com/logo.png",
  "client_uri": "https://app.example.com",
  "tos_uri": "https://app.example.com/tos",
  "policy_uri": "https://app.example.com/privacy",
  "contacts": ["admin@example.com"]
}
```

**Response:** `201 Created`

```json
{
  "client_id": "abc123-uuid",
  "client_secret": "xyz789-secret",
  "client_id_issued_at": 1699996399,
  "client_secret_expires_at": 0,
  "client_name": "My Application",
  "redirect_uris": ["https://app.example.com/callback"],
  "grant_types": ["authorization_code", "refresh_token"],
  "response_types": ["code"],
  "token_endpoint_auth_method": "client_secret_basic",
  "scope": "openid profile email"
}
```

**Validation:**
- `redirect_uris` must use HTTPS (except localhost for development)
- `redirect_uris` must not contain URL fragments

---

## Authentication Endpoints

### Sign In Form

<mark style="color:blue;">`GET`</mark> `/signin`

Display sign-in form.

**Query Parameters:**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `forward_url` | Optional | Base64-encoded redirect URL after login |

**Response:** HTML sign-in form

---

### Sign In

<mark style="color:green;">`POST`</mark> `/signin`

Authenticate user.

**Request Body (Form-encoded):**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `email` | Yes | User's email address |
| `password` | Yes | User's password |
| `forward_url` | Optional | Base64-encoded redirect URL |

**Response (Success):** `302` redirect to profile or forward_url

**Response (MFA Required):** `302` redirect to `/mfa/verify`

**Response (Account Locked):** `423 Locked` with `Retry-After` header

**Response (Invalid Credentials):** `401 Unauthorized`

---

### Sign Out

<mark style="color:green;">`POST`</mark> `/signout`

End user session.

**Response:** `302` redirect to sign-in page

---

## Account Endpoints

### Forgot Password

<mark style="color:blue;">`GET`</mark> `/forgot-password`

Display forgot password form.

---

<mark style="color:green;">`POST`</mark> `/forgot-password`

Request password reset email.

**Request Body (Form-encoded):**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `email` | Yes | User's email address |

**Response:** Always shows success (prevents email enumeration)

---

### Password Reset

<mark style="color:green;">`POST`</mark> `/account/password/reset`

Request password reset token.

**Request Body:**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `email` | Yes | User's email address |

**Response:** `200 OK` (always, to prevent enumeration)

---

<mark style="color:green;">`POST`</mark> `/account/password/confirm`

Complete password reset.

**Request Body:**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `token` | Yes | Reset token from email |
| `password` | Yes | New password |

**Response (Success):** `200 OK`

```json
{
  "success": true
}
```

**Response (Error):** `400 Bad Request`

```json
{
  "error": "invalid_token"
}
```

---

### Email Verification

<mark style="color:green;">`POST`</mark> `/account/email/verify`

Verify email address.

**Request Body:**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `token` | Yes | Verification token from email |

**Response:** `200 OK` or `400 Bad Request`

---

<mark style="color:green;">`POST`</mark> `/account/email/resend`

Resend verification email.

**Request Body:**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `email` | Yes | Email address |

**Response:** `200 OK`

---

## MFA Endpoints

### MFA Setup

<mark style="color:blue;">`GET`</mark> `/mfa/setup`

Display MFA setup with QR code.

**Response:** HTML page with:
- QR code for authenticator app
- Secret key (manual entry)
- Backup codes

**Authentication Required:** Yes (session)

---

### Enable MFA

<mark style="color:green;">`POST`</mark> `/mfa/enable`

Enable MFA for account.

**Request Body:**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `totp_code` | Yes | 6-digit verification code |

**Response:** `302` redirect

**Authentication Required:** Yes (session)

---

### Verify MFA

<mark style="color:green;">`POST`</mark> `/mfa/verify`

Verify MFA code during login.

**Request Body:**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `totp_code` | Yes | 6-digit code from authenticator |

**Response:** `302` redirect to profile

---

### Disable MFA

<mark style="color:green;">`POST`</mark> `/mfa/disable`

Disable MFA for account.

**Request Body:**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `password` | Yes | Current password for verification |

**Response:** `302` redirect

**Authentication Required:** Yes (session)

---

## User Profile

### View Profile

<mark style="color:blue;">`GET`</mark> `/profile`

Display user profile page.

**Response:** HTML profile page with:
- User details
- Email verification status
- MFA status
- Connected social accounts
- Active sessions

**Authentication Required:** Yes (session)

---

## Health Check

<mark style="color:blue;">`GET`</mark> `/health_check`

Check server health.

**Response:** `200 OK`

```json
{
  "status": "ok"
}
```

---

## Social Login

See [Social Login API](social-login.md) for social authentication endpoints.

---

## Next Steps

- [Social Login](social-login.md) - Social authentication endpoints
- [Error Codes](error-codes.md) - Error response reference
- [Rate Limits](rate-limits.md) - Rate limiting details
- [OAuth 2.0 Flows](../oauth2/README.md) - Grant type specifications
