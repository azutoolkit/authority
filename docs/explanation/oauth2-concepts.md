# OAuth 2.0 Concepts

Understanding the fundamentals of OAuth 2.0.

## What is OAuth 2.0?

OAuth 2.0 is an authorization framework that enables applications to obtain limited access to user resources without exposing credentials.

### The Problem OAuth Solves

Without OAuth, applications would need:

- Direct access to user credentials
- Full access to all resources
- No way to revoke access without changing passwords

OAuth provides:

- Delegated authorization (no password sharing)
- Scoped access (limited permissions)
- Revocable tokens (easy access removal)

## Key Concepts

### Roles

```
┌──────────────────────────────────────────────────┐
│                                                  │
│   Resource Owner         Authorization Server    │
│   (User)                 (Authority)             │
│      │                        │                  │
│      │ authorizes             │ issues tokens    │
│      ▼                        ▼                  │
│   Client ◄─────────────────────────────────►     │
│   (App)                  Resource Server         │
│                          (API)                   │
│                                                  │
└──────────────────────────────────────────────────┘
```

| Role | Description |
|------|-------------|
| **Resource Owner** | The user who owns the data |
| **Client** | The application requesting access |
| **Authorization Server** | Issues tokens after authorization |
| **Resource Server** | Hosts the protected resources (API) |

### Tokens

| Token | Purpose | Lifetime |
|-------|---------|----------|
| **Authorization Code** | Exchanged for tokens | Minutes |
| **Access Token** | Authorizes API requests | Hours |
| **Refresh Token** | Gets new access tokens | Days/Weeks |

### Scopes

Scopes define what access is granted:

```
Full User Data
├── profile (name, picture)
├── email (email address)
├── read (read-only access)
├── write (modify data)
└── admin (administrative access)
```

Clients request scopes:
```
scope=profile email read
```

Users consent to scopes:
```
"App X wants to access your profile and email"
```

## Grant Types

### Authorization Code (Most Common)

Best for: Web applications with a backend

```
User → Client → Authority → User (login) → Client (code) → Authority → Client (tokens)
```

The client never sees the user's password.

### Authorization Code + PKCE

Best for: Mobile apps, single-page applications

Same as authorization code, but with proof key:

1. Client generates random `code_verifier`
2. Client sends `code_challenge = SHA256(code_verifier)`
3. Authority returns code
4. Client proves identity with `code_verifier`

### Client Credentials

Best for: Machine-to-machine

```
Service → Authority (client_id + secret) → Service (token)
```

No user involved - the service itself is authorized.

### Device Code

Best for: TVs, CLI tools, IoT

```
Device → Authority (get code)
Device → User: "Go to URL, enter code"
User → Authority (enter code, approve)
Device → Authority (poll for token)
```

## The Authorization Flow

### Step by Step

1. **User wants to access protected resource**

   User clicks "Login with Authority" in your app.

2. **Client redirects to Authorization Server**

   ```
   GET /authorize?
     response_type=code
     &client_id=abc123
     &redirect_uri=https://app.example.com/callback
     &scope=profile email
     &state=xyz789
   ```

3. **User authenticates**

   Authority shows login page. User enters credentials.

4. **User authorizes**

   Authority shows consent screen. User approves scopes.

5. **Authorization Server redirects back**

   ```
   https://app.example.com/callback?
     code=AUTH_CODE_HERE
     &state=xyz789
   ```

6. **Client exchanges code for tokens**

   ```
   POST /token
   grant_type=authorization_code
   &code=AUTH_CODE_HERE
   &redirect_uri=https://app.example.com/callback
   &client_id=abc123
   &client_secret=secret123
   ```

7. **Client receives tokens**

   ```json
   {
     "access_token": "eyJhbG...",
     "refresh_token": "dGhpc...",
     "expires_in": 3600
   }
   ```

8. **Client uses access token**

   ```
   GET /api/user
   Authorization: Bearer eyJhbG...
   ```

## Security Concepts

### State Parameter

Prevents CSRF attacks:

1. Client generates random state
2. Client stores state in session
3. Client includes state in authorization request
4. Authority returns state in callback
5. Client verifies state matches

### PKCE

Prevents authorization code interception:

```
                            Attacker
                               │
┌─────────┐                    │                    ┌─────────┐
│ Client  │───code_challenge───┼───────────────────►│Authority│
│         │◄──authorization_code◄──────────────────│         │
│         │───code_verifier────┼────────────────────►│         │
│         │◄──access_token─────┼────────────────────│         │
└─────────┘                    │                    └─────────┘
                               │
                    Attacker has code,
                    but can't prove
                    they know verifier
```

### Token Security

- **Short-lived access tokens** - Limit exposure window
- **Token rotation** - New refresh token each use
- **Secure storage** - Never store in URL or logs

## Common Misconceptions

### "OAuth is for authentication"

OAuth is for **authorization** (what you can do), not authentication (who you are). OpenID Connect adds authentication.

### "The access token contains user data"

Access tokens authorize access - they don't necessarily contain user info. Use the UserInfo endpoint or ID tokens for identity.

### "Longer token lifetimes are more secure"

Shorter lifetimes with refresh tokens are more secure. If a token is compromised, the damage window is limited.

## Next Steps

- [OpenID Connect Concepts](openid-connect-concepts.md) - Identity layer
- [Choosing Grant Types](grant-type-selection.md) - Decision guide
- [Token Lifecycle](token-lifecycle.md) - Token management
