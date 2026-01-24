# Implicit Grant (Legacy)

{% hint style="danger" %}
**Deprecated:** The implicit grant is no longer recommended for new applications. Use [Authorization Code + PKCE](../authorization-code-pkce.md) instead.
{% endhint %}

## Overview

The implicit grant returns tokens directly in the URL fragment. It was designed for browser-based applications before PKCE existed.

## Why It's Deprecated

- **Tokens exposed in URL** - Visible in browser history and logs
- **No refresh tokens** - Users must re-authenticate frequently
- **Vulnerable to interception** - No protection against token leakage
- **PKCE is better** - Authorization code + PKCE is now preferred

## Flow

```
User → Client → Authority → Client (with token in URL fragment)
```

## Authorization Request

```bash
GET /authorize?
  response_type=token
  &client_id=abc123
  &redirect_uri=https://app.example.com/callback
  &scope=openid%20profile
  &state=xyz789
```

## Response

```
https://app.example.com/callback#
  access_token=eyJhbGciOiJSUzI1NiIs...
  &token_type=Bearer
  &expires_in=3600
  &state=xyz789
```

Note: Token is in URL fragment (`#`), not query string.

## Migration to PKCE

Replace implicit grant with authorization code + PKCE:

**Before (Implicit):**
```javascript
// Redirect with response_type=token
window.location = '/authorize?response_type=token&client_id=...';

// Get token from URL fragment
const token = new URLSearchParams(window.location.hash.slice(1)).get('access_token');
```

**After (PKCE):**
```javascript
// Generate PKCE values
const verifier = generateCodeVerifier();
const challenge = await generateCodeChallenge(verifier);

// Redirect with response_type=code
window.location = `/authorize?response_type=code&client_id=...&code_challenge=${challenge}&code_challenge_method=S256`;

// Exchange code for token
const tokenResponse = await fetch('/token', {
  method: 'POST',
  body: new URLSearchParams({
    grant_type: 'authorization_code',
    code: code,
    code_verifier: verifier,
    client_id: CLIENT_ID
  })
});
```

## Next Steps

- [Authorization Code + PKCE](../authorization-code-pkce.md) - Recommended replacement
- [OAuth 2.0 Reference](../README.md) - All grant types
