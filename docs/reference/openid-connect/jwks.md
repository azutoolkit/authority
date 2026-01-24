# JSON Web Key Set (JWKS)

The JWKS endpoint provides public keys for verifying JWT signatures.

## JWKS Endpoint

<mark style="color:blue;">`GET`</mark> `/.well-known/jwks.json`

Returns the public keys used to sign tokens.

## Response

```json
{
  "keys": [
    {
      "kty": "RSA",
      "kid": "authority-key-1",
      "use": "sig",
      "alg": "RS256",
      "n": "0vx7agoebGcQSuuPiLJXZpt...",
      "e": "AQAB"
    }
  ]
}
```

## Key Properties

| Property | Description |
|----------|-------------|
| `kty` | Key type (`RSA`) |
| `kid` | Key ID (used in JWT header) |
| `use` | Key usage (`sig` for signing) |
| `alg` | Algorithm (`RS256`) |
| `n` | RSA modulus (Base64URL) |
| `e` | RSA exponent (Base64URL) |

## Token Verification

### JavaScript

```javascript
const jwt = require('jsonwebtoken');
const jwksClient = require('jwks-rsa');

const client = jwksClient({
  jwksUri: 'https://auth.example.com/.well-known/jwks.json',
  cache: true,
  cacheMaxAge: 600000, // 10 minutes
  rateLimit: true,
  jwksRequestsPerMinute: 10
});

function getKey(header, callback) {
  client.getSigningKey(header.kid, (err, key) => {
    if (err) {
      callback(err);
      return;
    }
    callback(null, key.getPublicKey());
  });
}

function verifyToken(token) {
  return new Promise((resolve, reject) => {
    jwt.verify(token, getKey, {
      algorithms: ['RS256'],
      issuer: 'https://auth.example.com'
    }, (err, decoded) => {
      if (err) reject(err);
      else resolve(decoded);
    });
  });
}
```

### Python

```python
import jwt
from jwt import PyJWKClient

jwks_client = PyJWKClient(
    "https://auth.example.com/.well-known/jwks.json"
)

def verify_token(token):
    signing_key = jwks_client.get_signing_key_from_jwt(token)

    return jwt.decode(
        token,
        signing_key.key,
        algorithms=["RS256"],
        issuer="https://auth.example.com",
        audience="your_client_id"
    )
```

### Go

```go
import (
    "github.com/golang-jwt/jwt/v5"
    "github.com/MicahParks/keyfunc/v2"
)

func verifyToken(tokenString string) (*jwt.Token, error) {
    jwks, err := keyfunc.Get("https://auth.example.com/.well-known/jwks.json", keyfunc.Options{})
    if err != nil {
        return nil, err
    }

    return jwt.Parse(tokenString, jwks.Keyfunc, jwt.WithIssuer("https://auth.example.com"))
}
```

## Key Matching

JWTs include the key ID in the header:

```json
{
  "alg": "RS256",
  "typ": "JWT",
  "kid": "authority-key-1"
}
```

Match this `kid` with the key in JWKS.

## Caching

JWKS should be cached to avoid excessive requests:

```javascript
const jwksClient = require('jwks-rsa');

const client = jwksClient({
  jwksUri: 'https://auth.example.com/.well-known/jwks.json',
  cache: true,
  cacheMaxAge: 600000,  // 10 minutes
  timeout: 30000        // 30 seconds timeout
});
```

## Key Rotation

Authority may rotate keys periodically:

1. New key added to JWKS
2. New tokens signed with new key
3. Old key remains for existing token validation
4. Eventually old key is removed

Your verification code should:

- Cache JWKS but refresh periodically
- Handle multiple keys in the set
- Match key by `kid` from token header

## Manual Verification

```javascript
const crypto = require('crypto');

async function manualVerify(token) {
  const [headerB64, payloadB64, signatureB64] = token.split('.');

  // Decode header to get kid
  const header = JSON.parse(Buffer.from(headerB64, 'base64url'));

  // Fetch JWKS
  const response = await fetch('https://auth.example.com/.well-known/jwks.json');
  const jwks = await response.json();

  // Find matching key
  const jwk = jwks.keys.find(k => k.kid === header.kid);
  if (!jwk) throw new Error('Key not found');

  // Convert JWK to PEM
  const pem = jwkToPem(jwk);

  // Verify signature
  const verifier = crypto.createVerify('RSA-SHA256');
  verifier.update(`${headerB64}.${payloadB64}`);

  const signature = Buffer.from(signatureB64, 'base64url');
  const isValid = verifier.verify(pem, signature);

  if (!isValid) throw new Error('Invalid signature');

  return JSON.parse(Buffer.from(payloadB64, 'base64url'));
}
```

## Next Steps

- [ID Tokens](id-tokens.md) - Token structure
- [UserInfo](userinfo.md) - User claims
- [Discovery](discovery.md) - Provider configuration
