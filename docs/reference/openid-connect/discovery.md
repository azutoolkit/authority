# Discovery

OpenID Connect Discovery allows clients to automatically configure themselves.

## Discovery Endpoint

<mark style="color:blue;">`GET`</mark> `/.well-known/openid-configuration`

Returns a JSON document with all provider configuration.

## Response

```json
{
  "issuer": "https://auth.example.com",
  "authorization_endpoint": "https://auth.example.com/authorize",
  "token_endpoint": "https://auth.example.com/token",
  "userinfo_endpoint": "https://auth.example.com/userinfo",
  "jwks_uri": "https://auth.example.com/.well-known/jwks.json",
  "registration_endpoint": "https://auth.example.com/register",
  "revocation_endpoint": "https://auth.example.com/token/revoke",
  "introspection_endpoint": "https://auth.example.com/token/introspect",
  "device_authorization_endpoint": "https://auth.example.com/device",

  "scopes_supported": [
    "openid",
    "profile",
    "email",
    "address",
    "phone",
    "offline_access"
  ],

  "response_types_supported": [
    "code",
    "token",
    "id_token",
    "code token",
    "code id_token",
    "token id_token",
    "code token id_token"
  ],

  "response_modes_supported": [
    "query",
    "fragment"
  ],

  "grant_types_supported": [
    "authorization_code",
    "refresh_token",
    "client_credentials",
    "urn:ietf:params:oauth:grant-type:device_code"
  ],

  "subject_types_supported": [
    "public"
  ],

  "id_token_signing_alg_values_supported": [
    "RS256"
  ],

  "token_endpoint_auth_methods_supported": [
    "client_secret_basic",
    "client_secret_post",
    "none"
  ],

  "claims_supported": [
    "sub",
    "iss",
    "aud",
    "exp",
    "iat",
    "auth_time",
    "nonce",
    "name",
    "given_name",
    "family_name",
    "email",
    "email_verified",
    "picture",
    "locale"
  ],

  "code_challenge_methods_supported": [
    "S256",
    "plain"
  ]
}
```

## Fields

### Core Endpoints

| Field | Description |
|-------|-------------|
| `issuer` | Provider identifier (base URL) |
| `authorization_endpoint` | URL for authorization requests |
| `token_endpoint` | URL for token requests |
| `userinfo_endpoint` | URL for user information |
| `jwks_uri` | URL for JSON Web Key Set |

### Additional Endpoints

| Field | Description |
|-------|-------------|
| `registration_endpoint` | Dynamic client registration |
| `revocation_endpoint` | Token revocation |
| `introspection_endpoint` | Token introspection |
| `device_authorization_endpoint` | Device flow |

### Supported Features

| Field | Description |
|-------|-------------|
| `scopes_supported` | Available scopes |
| `response_types_supported` | Supported response types |
| `grant_types_supported` | Supported grant types |
| `token_endpoint_auth_methods_supported` | Client authentication methods |
| `claims_supported` | Available user claims |

## Usage

### JavaScript

```javascript
async function discoverProvider(issuer) {
  const response = await fetch(
    `${issuer}/.well-known/openid-configuration`
  );
  return response.json();
}

// Use discovered configuration
const config = await discoverProvider('https://auth.example.com');

// Now use the endpoints
const authUrl = new URL(config.authorization_endpoint);
authUrl.searchParams.set('client_id', CLIENT_ID);
authUrl.searchParams.set('response_type', 'code');
// ...
```

### Python

```python
import requests

def discover_provider(issuer):
    response = requests.get(
        f"{issuer}/.well-known/openid-configuration"
    )
    return response.json()

config = discover_provider('https://auth.example.com')
print(f"Auth endpoint: {config['authorization_endpoint']}")
```

## Caching

Discovery documents should be cached:

```javascript
class ProviderConfig {
  constructor(issuer) {
    this.issuer = issuer;
    this.config = null;
    this.expiresAt = null;
  }

  async getConfig() {
    // Cache for 1 hour
    if (this.config && Date.now() < this.expiresAt) {
      return this.config;
    }

    const response = await fetch(
      `${this.issuer}/.well-known/openid-configuration`
    );
    this.config = await response.json();
    this.expiresAt = Date.now() + (60 * 60 * 1000);

    return this.config;
  }
}
```

## Validation

Clients should verify:

1. `issuer` matches the expected provider
2. Required endpoints are present
3. Needed scopes/grant types are supported
4. Signing algorithms are acceptable

```javascript
function validateConfig(config, expectedIssuer) {
  if (config.issuer !== expectedIssuer) {
    throw new Error('Issuer mismatch');
  }

  if (!config.authorization_endpoint) {
    throw new Error('Missing authorization endpoint');
  }

  if (!config.scopes_supported.includes('openid')) {
    throw new Error('OpenID scope not supported');
  }

  return true;
}
```

## Next Steps

- [JWKS](jwks.md) - Public keys for verification
- [UserInfo](userinfo.md) - User claims endpoint
- [ID Tokens](id-tokens.md) - Token specification
