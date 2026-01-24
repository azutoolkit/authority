# Token Response

Reference for OAuth 2.0 token endpoint responses.

## Successful Response

```json
HTTP/1.1 200 OK
Content-Type: application/json
Cache-Control: no-store

{
  "access_token": "eyJhbGciOiJSUzI1NiIs...",
  "token_type": "Bearer",
  "expires_in": 3600,
  "refresh_token": "dGhpcyBpcyBhIHJlZnJlc2g...",
  "scope": "openid profile email",
  "id_token": "eyJhbGciOiJSUzI1NiIs..."
}
```

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `access_token` | String | The access token |
| `token_type` | String | Always `Bearer` |
| `expires_in` | Integer | Token lifetime in seconds |
| `refresh_token` | String | Token for renewal (optional) |
| `scope` | String | Granted scopes (space-separated) |
| `id_token` | String | OIDC ID token (when openid scope) |

## Access Token Format

Authority issues JWTs as access tokens:

```
eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImF1dGhvcml0eS1rZXktMSJ9.eyJpc3MiOiJodHRwczovL2F1dGguZXhhbXBsZS5jb20iLCJzdWIiOiJ1c2VyLXV1aWQiLCJhdWQiOiJhYmMxMjMiLCJleHAiOjE2OTk5OTk5OTksImlhdCI6MTY5OTk5NjM5OSwic2NvcGUiOiJvcGVuaWQgcHJvZmlsZSBlbWFpbCJ9.signature
```

### Decoded JWT

**Header:**
```json
{
  "alg": "RS256",
  "typ": "JWT",
  "kid": "authority-key-1"
}
```

**Payload:**
```json
{
  "iss": "https://auth.example.com",
  "sub": "user-uuid",
  "aud": "abc123",
  "exp": 1699999999,
  "iat": 1699996399,
  "scope": "openid profile email",
  "client_id": "abc123"
}
```

### JWT Claims

| Claim | Description |
|-------|-------------|
| `iss` | Issuer (Authority URL) |
| `sub` | Subject (user ID) |
| `aud` | Audience (client ID) |
| `exp` | Expiration time |
| `iat` | Issued at time |
| `scope` | Granted scopes |
| `client_id` | Client identifier |

## Token Types by Grant

### Authorization Code

```json
{
  "access_token": "...",
  "token_type": "Bearer",
  "expires_in": 3600,
  "refresh_token": "...",
  "scope": "openid profile email",
  "id_token": "..."
}
```

### Client Credentials

```json
{
  "access_token": "...",
  "token_type": "Bearer",
  "expires_in": 3600,
  "scope": "read write"
}
```

No refresh token or ID token for client credentials.

### Refresh Token

```json
{
  "access_token": "...",
  "token_type": "Bearer",
  "expires_in": 3600,
  "refresh_token": "...",
  "scope": "openid profile email"
}
```

New refresh token issued (rotation).

## Bearer Token Usage

Use the access token in API requests:

### Authorization Header (Recommended)

```
GET /api/resource HTTP/1.1
Host: api.example.com
Authorization: Bearer eyJhbGciOiJSUzI1NiIs...
```

### Query Parameter (Not Recommended)

```
GET /api/resource?access_token=eyJhbGciOiJSUzI1NiIs...
```

{% hint style="warning" %}
Query parameter usage exposes tokens in logs and browser history.
{% endhint %}

## Error Response

```json
HTTP/1.1 400 Bad Request
Content-Type: application/json

{
  "error": "invalid_grant",
  "error_description": "The authorization code has expired"
}
```

See [Error Codes](../api/error-codes.md) for all error types.

## Token Validation

### JWT Validation Steps

1. **Parse** the JWT
2. **Verify signature** using JWKS
3. **Check issuer** matches Authority URL
4. **Check audience** matches your client ID
5. **Check expiration** is in the future
6. **Check scope** includes required permissions

### Example Validation

```javascript
const jwt = require('jsonwebtoken');
const jwksClient = require('jwks-rsa');

const client = jwksClient({
  jwksUri: 'https://auth.example.com/.well-known/jwks.json'
});

function getKey(header, callback) {
  client.getSigningKey(header.kid, (err, key) => {
    callback(err, key?.getPublicKey());
  });
}

function validateToken(token) {
  return new Promise((resolve, reject) => {
    jwt.verify(token, getKey, {
      algorithms: ['RS256'],
      issuer: 'https://auth.example.com',
      audience: 'your_client_id'
    }, (err, decoded) => {
      if (err) reject(err);
      else resolve(decoded);
    });
  });
}
```

## Token Introspection

For opaque tokens or real-time validation:

```bash
POST /token/introspect HTTP/1.1
Authorization: Basic YWJjMTIzOnNlY3JldA==
Content-Type: application/x-www-form-urlencoded

token=eyJhbGciOiJSUzI1NiIs...
```

Response:
```json
{
  "active": true,
  "client_id": "abc123",
  "username": "user@example.com",
  "scope": "openid profile email",
  "sub": "user-uuid",
  "exp": 1699999999
}
```

## Caching

HTTP headers prevent caching:

```
Cache-Control: no-store
Pragma: no-cache
```

Never cache token responses.

## Next Steps

- [Refresh Tokens](refresh-tokens.md) - Token renewal
- [Error Codes](../api/error-codes.md) - Error handling
- [Token Lifecycle](../../explanation/token-lifecycle.md) - Conceptual overview
