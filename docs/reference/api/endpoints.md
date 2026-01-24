# API Endpoints

Complete reference for all Authority API endpoints.

## OAuth 2.0 Endpoints

### Authorization Endpoint

<mark style="color:blue;">`GET`</mark> `/authorize`

Initiates the OAuth 2.0 authorization flow.

**Query Parameters:**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `response_type` | Yes | Must be `code` |
| `client_id` | Yes | The client identifier |
| `redirect_uri` | Yes | Callback URL |
| `scope` | Yes | Space-separated scopes |
| `state` | Recommended | CSRF protection token |
| `code_challenge` | For PKCE | Base64URL-encoded challenge |
| `code_challenge_method` | For PKCE | `S256` or `plain` |

**Example:**

```bash
GET /authorize?response_type=code&client_id=abc123&redirect_uri=https://app.example.com/callback&scope=openid%20profile&state=xyz789
```

**Response:** Redirects to login page, then to `redirect_uri` with `code` parameter.

---

### Token Endpoint

<mark style="color:green;">`POST`</mark> `/token`

Exchange authorization code or refresh token for access tokens.

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

**Response:**

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

<mark style="color:green;">`POST`</mark> `/token/introspect`

Validate a token and get its metadata.

**Request Body:**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `token` | Yes | Token to introspect |
| `token_type_hint` | Optional | `access_token` or `refresh_token` |

**Response (Active Token):**

```json
{
  "active": true,
  "client_id": "abc123",
  "username": "user@example.com",
  "scope": "openid profile email",
  "sub": "user-uuid",
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

<mark style="color:green;">`POST`</mark> `/token/revoke`

Revoke an access or refresh token.

**Request Body:**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `token` | Yes | Token to revoke |
| `token_type_hint` | Optional | `access_token` or `refresh_token` |

**Response:** `200 OK` (always, per RFC 7009)

---

### Device Authorization

<mark style="color:green;">`POST`</mark> `/device`

Start device authorization flow.

**Request Body:**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `client_id` | Yes | Client identifier |
| `scope` | Optional | Requested scopes |

**Response:**

```json
{
  "device_code": "e2623df1-8594-47b4-b528-41ed3daecc1a",
  "user_code": "56933A",
  "verification_uri": "https://auth.example.com/activate",
  "verification_uri_complete": "https://auth.example.com/activate?user_code=56933A",
  "expires_in": 300,
  "interval": 5
}
```

---

## OpenID Connect Endpoints

### UserInfo

<mark style="color:blue;">`GET`</mark> `/userinfo`
<mark style="color:green;">`POST`</mark> `/userinfo`

Get authenticated user's claims.

**Headers:**

| Header | Description |
|--------|-------------|
| `Authorization` | `Bearer {access_token}` |

**Response:**

```json
{
  "sub": "user-uuid",
  "name": "John Doe",
  "given_name": "John",
  "family_name": "Doe",
  "email": "john@example.com",
  "email_verified": true,
  "picture": "https://..."
}
```

---

### Discovery

<mark style="color:blue;">`GET`</mark> `/.well-known/openid-configuration`

OpenID Connect discovery document.

**Response:**

```json
{
  "issuer": "https://auth.example.com",
  "authorization_endpoint": "https://auth.example.com/authorize",
  "token_endpoint": "https://auth.example.com/token",
  "userinfo_endpoint": "https://auth.example.com/userinfo",
  "jwks_uri": "https://auth.example.com/.well-known/jwks.json",
  "scopes_supported": ["openid", "profile", "email"],
  "response_types_supported": ["code"],
  "grant_types_supported": ["authorization_code", "refresh_token", "client_credentials"]
}
```

---

### JWKS

<mark style="color:blue;">`GET`</mark> `/.well-known/jwks.json`

JSON Web Key Set for token verification.

**Response:**

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

---

## Client Registration

### Register Client

<mark style="color:green;">`POST`</mark> `/register`

Dynamically register an OAuth client.

**Request Body:**

```json
{
  "client_name": "My Application",
  "redirect_uris": ["https://app.example.com/callback"],
  "grant_types": ["authorization_code", "refresh_token"],
  "response_types": ["code"],
  "scope": "openid profile email"
}
```

**Response:**

```json
{
  "client_id": "abc123",
  "client_secret": "xyz789",
  "client_name": "My Application",
  "redirect_uris": ["https://app.example.com/callback"]
}
```

---

### Get Client

<mark style="color:blue;">`GET`</mark> `/register/{client_id}`

Get client details.

---

### Update Client

<mark style="color:orange;">`PATCH`</mark> `/register/{client_id}`

Update client configuration.

---

### Delete Client

<mark style="color:red;">`DELETE`</mark> `/register/{client_id}`

Delete a client.

---

### Rotate Secret

<mark style="color:green;">`POST`</mark> `/register/{client_id}/renew_secret`

Generate new client secret.

---

## Session Endpoints

### Login

<mark style="color:green;">`POST`</mark> `/sessions/login`

Authenticate user.

**Request Body:**

```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

---

### Logout

<mark style="color:green;">`POST`</mark> `/sessions/logout`

End user session.

---

## Health Check

<mark style="color:blue;">`GET`</mark> `/health`

Check server health.

**Response:**

```json
{
  "status": "healthy",
  "version": "1.0.0"
}
```

## Next Steps

- [Error Codes](error-codes.md) - Error response reference
- [Rate Limits](rate-limits.md) - Rate limiting details
- [OAuth 2.0 Flows](../oauth2/README.md) - Grant type specifications
