# Protect Your API

Learn how to secure your API endpoints using Authority's token validation.

## Prerequisites

- Completed [First OAuth Integration](first-oauth-integration.md)
- A backend API you want to protect

## What You'll Learn

- Validate access tokens server-side
- Implement scope-based access control
- Handle token expiration gracefully

## Token Validation Approaches

There are two ways to validate tokens:

1. **Local validation** - Verify JWT signature using Authority's public keys
2. **Token introspection** - Ask Authority if the token is valid

### When to Use Each

| Approach | Use When |
|----------|----------|
| Local validation | Low latency required, stateless validation |
| Token introspection | Need real-time revocation checks, opaque tokens |

## Approach 1: Local JWT Validation

### Step 1: Fetch the JWKS

Authority publishes its public keys at `/.well-known/jwks.json`:

```bash
curl http://localhost:4000/.well-known/jwks.json
```

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

### Step 2: Validate the Token

**Node.js Example:**

```javascript
const jwt = require('jsonwebtoken');
const jwksClient = require('jwks-rsa');

const client = jwksClient({
  jwksUri: 'http://localhost:4000/.well-known/jwks.json',
  cache: true,
  rateLimit: true
});

function getKey(header, callback) {
  client.getSigningKey(header.kid, (err, key) => {
    callback(err, key?.getPublicKey());
  });
}

async function validateToken(token) {
  return new Promise((resolve, reject) => {
    jwt.verify(token, getKey, {
      algorithms: ['RS256'],
      issuer: 'http://localhost:4000'
    }, (err, decoded) => {
      if (err) reject(err);
      else resolve(decoded);
    });
  });
}
```

**Python Example:**

```python
import jwt
import requests
from jwt import PyJWKClient

jwks_client = PyJWKClient("http://localhost:4000/.well-known/jwks.json")

def validate_token(token):
    signing_key = jwks_client.get_signing_key_from_jwt(token)
    return jwt.decode(
        token,
        signing_key.key,
        algorithms=["RS256"],
        issuer="http://localhost:4000"
    )
```

### Step 3: Create Middleware

**Express.js Middleware:**

```javascript
async function authMiddleware(req, res, next) {
  const authHeader = req.headers.authorization;

  if (!authHeader?.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Missing token' });
  }

  const token = authHeader.substring(7);

  try {
    const decoded = await validateToken(token);
    req.user = decoded;
    next();
  } catch (err) {
    return res.status(401).json({ error: 'Invalid token' });
  }
}

// Use it
app.get('/api/protected', authMiddleware, (req, res) => {
  res.json({ message: `Hello, ${req.user.sub}` });
});
```

## Approach 2: Token Introspection

For real-time validation, use the introspection endpoint.

### Step 1: Configure Client Credentials

Token introspection requires client authentication:

```javascript
const CLIENT_ID = 'your_client_id';
const CLIENT_SECRET = 'your_client_secret';
```

### Step 2: Introspect the Token

```javascript
async function introspectToken(token) {
  const credentials = Buffer.from(`${CLIENT_ID}:${CLIENT_SECRET}`).toString('base64');

  const response = await fetch('http://localhost:4000/token/introspect', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': `Basic ${credentials}`
    },
    body: new URLSearchParams({
      token: token,
      token_type_hint: 'access_token'
    })
  });

  return response.json();
}
```

The response:

```json
{
  "active": true,
  "client_id": "my-client",
  "username": "user@example.com",
  "scope": "read write",
  "sub": "user-uuid",
  "exp": 1699999999
}
```

If the token is invalid or revoked:

```json
{
  "active": false
}
```

## Scope-Based Access Control

### Define Scopes

Configure scopes in Authority's admin dashboard:

| Scope | Description |
|-------|-------------|
| `read` | Read-only access |
| `write` | Create and update resources |
| `admin` | Administrative operations |

### Check Scopes in Middleware

```javascript
function requireScopes(...requiredScopes) {
  return async (req, res, next) => {
    const token = req.headers.authorization?.substring(7);

    if (!token) {
      return res.status(401).json({ error: 'Missing token' });
    }

    try {
      const decoded = await validateToken(token);
      const tokenScopes = decoded.scope?.split(' ') || [];

      const hasAllScopes = requiredScopes.every(
        scope => tokenScopes.includes(scope)
      );

      if (!hasAllScopes) {
        return res.status(403).json({
          error: 'Insufficient scope',
          required: requiredScopes,
          provided: tokenScopes
        });
      }

      req.user = decoded;
      next();
    } catch (err) {
      return res.status(401).json({ error: 'Invalid token' });
    }
  };
}

// Use it
app.get('/api/data', requireScopes('read'), (req, res) => {
  res.json({ data: '...' });
});

app.post('/api/data', requireScopes('write'), (req, res) => {
  res.json({ created: true });
});

app.delete('/api/users/:id', requireScopes('admin'), (req, res) => {
  res.json({ deleted: true });
});
```

## Handling Token Expiration

### Client-Side: Refresh Before Expiry

```javascript
function scheduleTokenRefresh(tokens) {
  const expiresIn = tokens.expires_in * 1000; // Convert to ms
  const refreshAt = expiresIn - 60000; // Refresh 1 minute early

  setTimeout(async () => {
    const newTokens = await refreshAccessToken(tokens.refresh_token);
    scheduleTokenRefresh(newTokens);
  }, refreshAt);
}
```

### Server-Side: Return Clear Errors

```javascript
app.use((err, req, res, next) => {
  if (err.name === 'TokenExpiredError') {
    return res.status(401).json({
      error: 'token_expired',
      message: 'Access token has expired'
    });
  }
  next(err);
});
```

## Next Steps

- [Add User Authentication](add-user-authentication.md) - OpenID Connect integration
- [Token Introspection Reference](../reference/oauth2/README.md) - Full specification
- [Refresh Tokens](../reference/oauth2/refresh-tokens.md) - Token renewal
