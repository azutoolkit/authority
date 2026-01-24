# Authorization Code Grant

The authorization code grant is used when an application exchanges an authorization code for an access token.

## Overview

This flow is for web applications with a server-side component that can securely store the client secret.

## Flow Diagram

```mermaid
sequenceDiagram
    participant U as User
    participant C as Client App
    participant A as Authority

    rect rgb(240, 240, 255)
        Note over U,A: Part 1: Authorization Request
        U->>C: 1. Click "Login"
        C->>A: 2. GET /authorize?response_type=code&client_id=...
        A->>U: 3. Show login form
        U->>A: 4. Enter credentials
        A->>U: 5. Show consent screen
        U->>A: 6. Approve scopes
        A->>C: 7. Redirect with code
    end

    rect rgb(240, 255, 240)
        Note over C,A: Part 2: Token Exchange
        C->>A: 8. POST /token (code + client_secret)
        A->>C: 9. Access token + Refresh token
    end

    rect rgb(255, 240, 240)
        Note over U,C: Part 3: Access Resources
        C->>U: 10. User logged in!
    end
```

## Authorization Request

<mark style="color:blue;">`GET`</mark> `/authorize`

Redirect the user to the authorization endpoint.

### Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `response_type` | Yes | Must be `code` |
| `client_id` | Yes | Your client identifier |
| `redirect_uri` | Yes | URL to redirect after authorization |
| `scope` | Yes | Space-separated scopes |
| `state` | Recommended | CSRF protection token |

### Example

```bash
GET https://auth.example.com/authorize?
  response_type=code
  &client_id=abc123
  &redirect_uri=https://app.example.com/callback
  &scope=openid%20profile%20email
  &state=xyz789
```

### Response

User is redirected to `redirect_uri` with:

```
https://app.example.com/callback?code=AUTH_CODE_HERE&state=xyz789
```

{% hint style="info" %}
Always verify the `state` parameter matches what you sent to prevent CSRF attacks.
{% endhint %}

## Token Request

<mark style="color:green;">`POST`</mark> `/token`

Exchange the authorization code for tokens.

### Headers

| Header | Value |
|--------|-------|
| `Content-Type` | `application/x-www-form-urlencoded` |
| `Authorization` | `Basic {base64(client_id:client_secret)}` |

### Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `grant_type` | Yes | Must be `authorization_code` |
| `code` | Yes | The authorization code |
| `redirect_uri` | Yes | Same as authorization request |

### Example

```bash
POST /token HTTP/1.1
Host: auth.example.com
Authorization: Basic YWJjMTIzOnNlY3JldA==
Content-Type: application/x-www-form-urlencoded

grant_type=authorization_code
&code=AUTH_CODE_HERE
&redirect_uri=https://app.example.com/callback
```

### Response

```json
{
  "access_token": "eyJhbGciOiJSUzI1NiIs...",
  "token_type": "Bearer",
  "expires_in": 3600,
  "refresh_token": "dGhpcyBpcyBhIHJlZnJlc2g...",
  "scope": "openid profile email"
}
```

## Complete Example

### Node.js

```javascript
const express = require('express');
const crypto = require('crypto');

const app = express();

const CLIENT_ID = 'your_client_id';
const CLIENT_SECRET = 'your_client_secret';
const REDIRECT_URI = 'http://localhost:3000/callback';
const AUTHORITY_URL = 'https://auth.example.com';

// Step 1: Redirect to authorization
app.get('/login', (req, res) => {
  const state = crypto.randomBytes(16).toString('hex');
  req.session.state = state;

  const params = new URLSearchParams({
    response_type: 'code',
    client_id: CLIENT_ID,
    redirect_uri: REDIRECT_URI,
    scope: 'openid profile email',
    state: state
  });

  res.redirect(`${AUTHORITY_URL}/authorize?${params}`);
});

// Step 2: Handle callback
app.get('/callback', async (req, res) => {
  const { code, state } = req.query;

  // Verify state
  if (state !== req.session.state) {
    return res.status(400).send('Invalid state');
  }

  // Exchange code for tokens
  const credentials = Buffer.from(`${CLIENT_ID}:${CLIENT_SECRET}`).toString('base64');

  const tokenResponse = await fetch(`${AUTHORITY_URL}/token`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': `Basic ${credentials}`
    },
    body: new URLSearchParams({
      grant_type: 'authorization_code',
      code: code,
      redirect_uri: REDIRECT_URI
    })
  });

  const tokens = await tokenResponse.json();
  req.session.tokens = tokens;

  res.redirect('/profile');
});
```

### Python

```python
from flask import Flask, redirect, request, session
import requests
import secrets

app = Flask(__name__)

CLIENT_ID = 'your_client_id'
CLIENT_SECRET = 'your_client_secret'
REDIRECT_URI = 'http://localhost:5000/callback'
AUTHORITY_URL = 'https://auth.example.com'

@app.route('/login')
def login():
    state = secrets.token_urlsafe(16)
    session['state'] = state

    params = {
        'response_type': 'code',
        'client_id': CLIENT_ID,
        'redirect_uri': REDIRECT_URI,
        'scope': 'openid profile email',
        'state': state
    }

    return redirect(f"{AUTHORITY_URL}/authorize?{urlencode(params)}")

@app.route('/callback')
def callback():
    code = request.args.get('code')
    state = request.args.get('state')

    if state != session.get('state'):
        return 'Invalid state', 400

    token_response = requests.post(
        f"{AUTHORITY_URL}/token",
        data={
            'grant_type': 'authorization_code',
            'code': code,
            'redirect_uri': REDIRECT_URI
        },
        auth=(CLIENT_ID, CLIENT_SECRET)
    )

    session['tokens'] = token_response.json()
    return redirect('/profile')
```

## Security Considerations

1. **Always validate state** - Prevents CSRF attacks
2. **Use HTTPS** - Never transmit tokens over HTTP
3. **Store secrets securely** - Never expose client_secret
4. **Validate redirect_uri** - Use exact match
5. **Short-lived codes** - Authorization codes expire quickly

## Next Steps

- [Authorization Code + PKCE](authorization-code-pkce.md) - For public clients
- [Refresh Tokens](refresh-tokens.md) - Token renewal
- [Token Response](token-response.md) - Response format
