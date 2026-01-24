# Manage Linked Accounts

Allow users to connect and disconnect social accounts from their profile.

## Overview

Users can:
- **Link** multiple social providers to one account
- **Unlink** social providers they no longer want
- **Sign in** with any linked provider

## Linking Accounts

### Automatic Linking

When a user signs in with a social provider:

1. **New user:** Account created automatically with social provider linked
2. **Existing user (same email):** Social provider linked to existing account
3. **Signed-in user:** Social provider added to their account

### Manual Linking

For signed-in users to add a social provider:

```html
<a href="https://your-authority-domain/auth/google?link=true">
  Connect Google Account
</a>
```

The user will:
1. Authenticate with the social provider
2. Return to Authority with provider linked
3. Continue with their existing session

## Unlinking Accounts

### API Endpoint

```
POST /auth/{provider}/unlink
```

**Request:**

```bash
curl -X POST https://your-authority-domain/auth/google/unlink \
  -H "Cookie: session=..." \
  -H "Content-Type: application/json"
```

**Response (Success):**

```json
{
  "success": true,
  "message": "Google account unlinked successfully"
}
```

**Response (Error):**

```json
{
  "error": "cannot_unlink",
  "message": "Cannot unlink the only login method. Set a password first."
}
```

### Safety Checks

Authority prevents unlinking when:

- It's the user's only login method
- User has no password set
- Would leave account inaccessible

**Solution:** User must set a password or link another provider first.

## User Interface

### Account Settings Page

Show users their linked accounts:

```javascript
// Fetch user's linked providers
const response = await fetch('https://your-authority-domain/userinfo', {
  headers: {
    'Authorization': `Bearer ${accessToken}`
  }
});

const userInfo = await response.json();
// Check for linked providers in user profile
```

### Example UI

```html
<div class="linked-accounts">
  <h3>Linked Accounts</h3>

  <div class="provider">
    <span class="icon">🔵</span>
    <span class="name">Google</span>
    <span class="email">user@gmail.com</span>
    <button onclick="unlinkProvider('google')">Disconnect</button>
  </div>

  <div class="provider">
    <span class="icon">⚫</span>
    <span class="name">GitHub</span>
    <span class="status">Not connected</span>
    <a href="/auth/github?link=true">Connect</a>
  </div>
</div>
```

### JavaScript Handler

```javascript
async function unlinkProvider(provider) {
  if (!confirm(`Disconnect ${provider}?`)) return;

  try {
    const response = await fetch(`/auth/${provider}/unlink`, {
      method: 'POST',
      credentials: 'include'
    });

    const result = await response.json();

    if (result.success) {
      // Refresh UI
      location.reload();
    } else {
      alert(result.message);
    }
  } catch (error) {
    alert('Failed to unlink account');
  }
}
```

## Security Considerations

### Account Takeover Prevention

When linking accounts, Authority verifies:

1. **Email match:** Social account email matches existing account
2. **Session valid:** User is properly authenticated
3. **State parameter:** CSRF protection via state validation

### Multiple Accounts Warning

If a social account is already linked to a different user:

```json
{
  "error": "already_linked",
  "message": "This social account is linked to another user"
}
```

The user must unlink from the other account first.

### Audit Logging

All link/unlink operations are recorded:

```json
{
  "event": "social_account_linked",
  "user_id": "user-uuid",
  "provider": "google",
  "provider_user_id": "google-user-id",
  "timestamp": "2024-01-15T10:30:00Z"
}

{
  "event": "social_account_unlinked",
  "user_id": "user-uuid",
  "provider": "github",
  "timestamp": "2024-01-15T11:45:00Z"
}
```

## Data Stored

For each linked social account:

| Field | Description |
|-------|-------------|
| `provider` | Provider name (google, github, etc.) |
| `provider_user_id` | Unique ID from provider |
| `email` | Email from provider |
| `name` | Name from provider |
| `avatar_url` | Profile picture URL |
| `access_token` | Provider access token (encrypted) |
| `refresh_token` | Provider refresh token (encrypted) |
| `token_expires_at` | Token expiration time |

## Best Practices

1. **Show linked status** - Display which providers are connected
2. **Confirm unlinking** - Require user confirmation
3. **Explain consequences** - Warn if unlinking removes login method
4. **Update UI immediately** - Reflect changes without page reload
5. **Log actions** - Track for security auditing

## Next Steps

- [Configure Google](configure-google.md) - Set up providers
- [Enable MFA](../security/enable-mfa.md) - Additional security
- [Audit Logging](../security/audit-logging.md) - Track account changes
