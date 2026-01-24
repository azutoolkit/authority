# ID Tokens

ID tokens are JWTs that contain claims about the authenticated user.

## Overview

ID tokens provide proof of authentication. Unlike access tokens (which authorize API access), ID tokens answer "who is this user?"

## Token Structure

ID tokens are JWTs with three parts:

```
eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImF1dGhvcml0eS1rZXktMSJ9.
eyJpc3MiOiJodHRwczovL2F1dGguZXhhbXBsZS5jb20iLCJzdWIiOiJ1c2VyLXV1aWQi...
.signature
```

## Decoded Token

### Header

```json
{
  "alg": "RS256",
  "typ": "JWT",
  "kid": "authority-key-1"
}
```

### Payload

```json
{
  "iss": "https://auth.example.com",
  "sub": "user-uuid",
  "aud": "client-id",
  "exp": 1699999999,
  "iat": 1699996399,
  "auth_time": 1699996300,
  "nonce": "n-0S6_WzA2Mj",
  "at_hash": "HK6E_P6Dh8Y93mRNtsDB1Q",
  "name": "John Doe",
  "email": "john@example.com",
  "email_verified": true
}
```

## Standard Claims

### Required Claims

| Claim | Description |
|-------|-------------|
| `iss` | Issuer (Authority URL) |
| `sub` | Subject (unique user ID) |
| `aud` | Audience (client ID) |
| `exp` | Expiration time |
| `iat` | Issued at time |

### Optional Claims

| Claim | Description |
|-------|-------------|
| `auth_time` | Time of authentication |
| `nonce` | Value from authorization request |
| `at_hash` | Access token hash |
| `c_hash` | Code hash (for hybrid flow) |
| `acr` | Authentication context class |
| `amr` | Authentication methods used |
| `azp` | Authorized party |

### Profile Claims

| Claim | Description |
|-------|-------------|
| `name` | Full name |
| `given_name` | First name |
| `family_name` | Last name |
| `email` | Email address |
| `email_verified` | Email verified |
| `picture` | Profile picture URL |

## Validation

### Required Steps

1. **Verify signature** using JWKS
2. **Check `iss`** matches expected issuer
3. **Check `aud`** contains your client ID
4. **Check `exp`** is in the future
5. **Check `iat`** is reasonable
6. **Check `nonce`** matches sent value (if used)

### JavaScript Example

```javascript
const jwt = require('jsonwebtoken');
const jwksClient = require('jwks-rsa');

const client = jwksClient({
  jwksUri: 'https://auth.example.com/.well-known/jwks.json'
});

async function validateIdToken(idToken, expectedNonce) {
  return new Promise((resolve, reject) => {
    const getKey = (header, callback) => {
      client.getSigningKey(header.kid, (err, key) => {
        callback(err, key?.getPublicKey());
      });
    };

    jwt.verify(idToken, getKey, {
      algorithms: ['RS256'],
      issuer: 'https://auth.example.com',
      audience: 'your_client_id'
    }, (err, decoded) => {
      if (err) {
        reject(err);
        return;
      }

      // Check nonce
      if (expectedNonce && decoded.nonce !== expectedNonce) {
        reject(new Error('Invalid nonce'));
        return;
      }

      // Check auth_time if max_age was requested
      // Check other claims as needed

      resolve(decoded);
    });
  });
}
```

### Python Example

```python
import jwt
from jwt import PyJWKClient

jwks_client = PyJWKClient("https://auth.example.com/.well-known/jwks.json")

def validate_id_token(id_token, expected_nonce=None):
    signing_key = jwks_client.get_signing_key_from_jwt(id_token)

    claims = jwt.decode(
        id_token,
        signing_key.key,
        algorithms=["RS256"],
        issuer="https://auth.example.com",
        audience="your_client_id"
    )

    if expected_nonce and claims.get('nonce') != expected_nonce:
        raise ValueError('Invalid nonce')

    return claims
```

## Using Nonce

Nonce prevents replay attacks:

### Request

```javascript
const nonce = generateRandomString();
sessionStorage.setItem('oidc_nonce', nonce);

const params = new URLSearchParams({
  response_type: 'code',
  client_id: CLIENT_ID,
  redirect_uri: REDIRECT_URI,
  scope: 'openid profile email',
  nonce: nonce
});
```

### Validation

```javascript
const savedNonce = sessionStorage.getItem('oidc_nonce');
const claims = await validateIdToken(tokens.id_token, savedNonce);
sessionStorage.removeItem('oidc_nonce');
```

## at_hash Validation

The `at_hash` claim allows ID token to be bound to access token:

```javascript
function validateAtHash(idToken, accessToken) {
  const claims = jwt.decode(idToken);

  if (claims.at_hash) {
    const hash = crypto.createHash('sha256').update(accessToken).digest();
    const expectedHash = hash.slice(0, hash.length / 2);
    const calculatedAtHash = base64url.encode(expectedHash);

    if (claims.at_hash !== calculatedAtHash) {
      throw new Error('at_hash mismatch');
    }
  }
}
```

## Common Issues

### "Invalid signature"

- Check JWKS URL is correct
- Verify key ID (kid) matches
- Ensure algorithm is RS256

### "Token expired"

- Check server/client time sync
- Token may have short lifetime
- Refresh authentication

### "Invalid audience"

- Verify client ID in validation
- Check token was issued for your client

## Next Steps

- [JWKS](jwks.md) - Token verification keys
- [UserInfo](userinfo.md) - Additional claims
- [Discovery](discovery.md) - Provider configuration
