# Client Credentials Grant

The client credentials grant is used for machine-to-machine authentication where no user is involved.

## Overview

This flow is for server-side applications that need to access resources on their own behalf, not on behalf of a user.

## Use Cases

- Background jobs
- Microservice communication
- API integrations
- Scheduled tasks
- System maintenance scripts

## Flow Diagram

```mermaid
sequenceDiagram
    participant C as Client Service
    participant A as Authority
    participant R as Resource Server

    C->>A: POST /token (client credentials)
    A->>A: Validate client_id and client_secret
    A->>C: Access token
    C->>R: Request with access token
    R->>C: Protected resource
```

## Token Request

<mark style="color:green;">`POST`</mark> `/token`

### Headers

| Header | Value |
|--------|-------|
| `Content-Type` | `application/x-www-form-urlencoded` |
| `Authorization` | `Basic {base64(client_id:client_secret)}` |

### Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `grant_type` | Yes | Must be `client_credentials` |
| `scope` | Optional | Space-separated scopes |

### Example

```bash
POST /token HTTP/1.1
Host: auth.example.com
Authorization: Basic YWJjMTIzOnNlY3JldA==
Content-Type: application/x-www-form-urlencoded

grant_type=client_credentials&scope=read%20write
```

### Response

```json
{
  "access_token": "eyJhbGciOiJSUzI1NiIs...",
  "token_type": "Bearer",
  "expires_in": 3600,
  "scope": "read write"
}
```

{% hint style="info" %}
Client credentials grant does not return a refresh token since the client can always request a new token.
{% endhint %}

## Authentication Methods

### HTTP Basic Authentication (Recommended)

```bash
Authorization: Basic base64(client_id:client_secret)
```

### POST Body

```bash
POST /token HTTP/1.1
Content-Type: application/x-www-form-urlencoded

grant_type=client_credentials
&client_id=abc123
&client_secret=your_secret
```

## Complete Examples

### Node.js

```javascript
const CLIENT_ID = 'your_client_id';
const CLIENT_SECRET = 'your_client_secret';
const AUTHORITY_URL = 'https://auth.example.com';

async function getAccessToken() {
  const credentials = Buffer.from(`${CLIENT_ID}:${CLIENT_SECRET}`).toString('base64');

  const response = await fetch(`${AUTHORITY_URL}/token`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': `Basic ${credentials}`
    },
    body: new URLSearchParams({
      grant_type: 'client_credentials',
      scope: 'read write'
    })
  });

  const data = await response.json();
  return data.access_token;
}

// Use the token
async function callApi() {
  const token = await getAccessToken();

  const response = await fetch('https://api.example.com/data', {
    headers: {
      'Authorization': `Bearer ${token}`
    }
  });

  return response.json();
}
```

### Python

```python
import requests
from requests.auth import HTTPBasicAuth

CLIENT_ID = 'your_client_id'
CLIENT_SECRET = 'your_client_secret'
AUTHORITY_URL = 'https://auth.example.com'

def get_access_token():
    response = requests.post(
        f'{AUTHORITY_URL}/token',
        data={
            'grant_type': 'client_credentials',
            'scope': 'read write'
        },
        auth=HTTPBasicAuth(CLIENT_ID, CLIENT_SECRET)
    )

    return response.json()['access_token']

# Use the token
def call_api():
    token = get_access_token()

    response = requests.get(
        'https://api.example.com/data',
        headers={'Authorization': f'Bearer {token}'}
    )

    return response.json()
```

### curl

```bash
# Get token
TOKEN=$(curl -s -X POST https://auth.example.com/token \
  -u "client_id:client_secret" \
  -d "grant_type=client_credentials" \
  -d "scope=read" \
  | jq -r '.access_token')

# Use token
curl https://api.example.com/data \
  -H "Authorization: Bearer $TOKEN"
```

## Token Caching

Since client credentials tokens have no refresh token, cache them:

```javascript
class TokenCache {
  constructor() {
    this.token = null;
    this.expiresAt = null;
  }

  async getToken() {
    // Return cached token if still valid
    if (this.token && Date.now() < this.expiresAt - 60000) {
      return this.token;
    }

    // Get new token
    const response = await fetchToken();
    this.token = response.access_token;
    this.expiresAt = Date.now() + (response.expires_in * 1000);

    return this.token;
  }
}

const tokenCache = new TokenCache();
```

## Scopes

Clients can only request scopes they're authorized for:

```bash
# Request specific scopes
grant_type=client_credentials&scope=read%20write

# If scope omitted, uses client's default scopes
grant_type=client_credentials
```

## Security Considerations

{% hint style="warning" %}
- **Protect credentials** - Store client secret securely
- **Use short token lifetimes** - Minimize exposure window
- **Rotate secrets regularly** - Limit compromise impact
- **Limit scopes** - Request only needed permissions
{% endhint %}

## Differences from Other Grants

| Aspect | Client Credentials | Authorization Code |
|--------|-------------------|-------------------|
| User involved | No | Yes |
| Refresh token | No | Yes |
| Use case | Service-to-service | User authentication |
| Client type | Confidential only | Both |

## Next Steps

- [Refresh Tokens](refresh-tokens.md) - Token renewal
- [Token Response](token-response.md) - Response format
- [Rotate Secrets](../../how-to/oauth-clients/rotate-secrets.md) - Secret management
