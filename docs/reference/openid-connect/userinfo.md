# UserInfo Endpoint

The UserInfo endpoint returns claims about the authenticated user.

## Endpoint

<mark style="color:blue;">`GET`</mark> `/userinfo`
<mark style="color:green;">`POST`</mark> `/userinfo`

Both methods are supported.

## Request

### Authorization Header

```bash
GET /userinfo HTTP/1.1
Host: auth.example.com
Authorization: Bearer eyJhbGciOiJSUzI1NiIs...
```

### POST with Form Body

```bash
POST /userinfo HTTP/1.1
Host: auth.example.com
Content-Type: application/x-www-form-urlencoded

access_token=eyJhbGciOiJSUzI1NiIs...
```

## Response

```json
{
  "sub": "user-uuid",
  "name": "John Doe",
  "given_name": "John",
  "family_name": "Doe",
  "preferred_username": "johnd",
  "email": "john@example.com",
  "email_verified": true,
  "picture": "https://example.com/johnd/photo.jpg",
  "locale": "en-US",
  "updated_at": 1699996399
}
```

## Claims by Scope

Claims returned depend on requested scopes:

### `openid` (required)

| Claim | Type | Description |
|-------|------|-------------|
| `sub` | String | Subject identifier |

### `profile`

| Claim | Type | Description |
|-------|------|-------------|
| `name` | String | Full name |
| `given_name` | String | First name |
| `family_name` | String | Last name |
| `middle_name` | String | Middle name |
| `nickname` | String | Casual name |
| `preferred_username` | String | Username |
| `profile` | String | Profile page URL |
| `picture` | String | Profile picture URL |
| `website` | String | Website URL |
| `gender` | String | Gender |
| `birthdate` | String | Birthday (YYYY-MM-DD) |
| `zoneinfo` | String | Timezone |
| `locale` | String | Locale |
| `updated_at` | Number | Last updated timestamp |

### `email`

| Claim | Type | Description |
|-------|------|-------------|
| `email` | String | Email address |
| `email_verified` | Boolean | Email verified |

### `address`

| Claim | Type | Description |
|-------|------|-------------|
| `address` | Object | Address object |

Address object:
```json
{
  "formatted": "123 Main St\nCity, State 12345",
  "street_address": "123 Main St",
  "locality": "City",
  "region": "State",
  "postal_code": "12345",
  "country": "US"
}
```

### `phone`

| Claim | Type | Description |
|-------|------|-------------|
| `phone_number` | String | Phone number |
| `phone_number_verified` | Boolean | Phone verified |

## Usage

### JavaScript

```javascript
async function getUserInfo(accessToken) {
  const response = await fetch('https://auth.example.com/userinfo', {
    headers: {
      'Authorization': `Bearer ${accessToken}`
    }
  });

  if (!response.ok) {
    throw new Error('Failed to fetch user info');
  }

  return response.json();
}

// Usage
const user = await getUserInfo(tokens.access_token);
console.log(`Hello, ${user.name}!`);
```

### Python

```python
import requests

def get_userinfo(access_token):
    response = requests.get(
        'https://auth.example.com/userinfo',
        headers={'Authorization': f'Bearer {access_token}'}
    )

    if response.status_code != 200:
        raise Exception('Failed to fetch user info')

    return response.json()

user = get_userinfo(tokens['access_token'])
print(f"Hello, {user['name']}!")
```

## Error Responses

### Invalid Token

```json
HTTP/1.1 401 Unauthorized
WWW-Authenticate: Bearer error="invalid_token", error_description="The access token is invalid"

{
  "error": "invalid_token",
  "error_description": "The access token is invalid"
}
```

### Expired Token

```json
HTTP/1.1 401 Unauthorized
WWW-Authenticate: Bearer error="invalid_token", error_description="The access token has expired"

{
  "error": "invalid_token",
  "error_description": "The access token has expired"
}
```

### Insufficient Scope

```json
HTTP/1.1 403 Forbidden
WWW-Authenticate: Bearer error="insufficient_scope", scope="openid profile"

{
  "error": "insufficient_scope",
  "error_description": "The access token lacks the required scope"
}
```

## UserInfo vs ID Token

| Aspect | ID Token | UserInfo |
|--------|----------|----------|
| Format | JWT (signed) | JSON |
| When received | Token response | Separate request |
| Purpose | Authentication proof | Additional claims |
| Freshness | Issued at auth time | Current values |

Use ID token for authentication, UserInfo for current profile data.

## Caching

UserInfo responses can be cached briefly:

```javascript
class UserInfoCache {
  constructor(ttl = 60000) { // 1 minute
    this.cache = new Map();
    this.ttl = ttl;
  }

  async get(accessToken) {
    const cached = this.cache.get(accessToken);
    if (cached && Date.now() < cached.expiresAt) {
      return cached.data;
    }

    const data = await fetchUserInfo(accessToken);
    this.cache.set(accessToken, {
      data,
      expiresAt: Date.now() + this.ttl
    });

    return data;
  }
}
```

## Next Steps

- [ID Tokens](id-tokens.md) - Token claims
- [JWKS](jwks.md) - Token verification
- [Discovery](discovery.md) - Endpoint discovery
