# Password Reset

Configure and manage password reset flows in Authority.

## User Self-Service Reset

### Reset Flow

1. User clicks **Forgot Password** on login page
2. Enters email address
3. Receives reset link via email
4. Clicks link and sets new password
5. Logs in with new password

### Request Reset

Users visit `/forgot-password` and enter their email.

### Reset Email

Authority sends an email with a secure reset link:

```
Subject: Reset your password

Click the link below to reset your password:
https://auth.example.com/reset-password?token=abc123...

This link expires in 1 hour.

If you didn't request this, ignore this email.
```

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PASSWORD_RESET_TTL` | `3600` | Reset token lifetime (seconds) |
| `PASSWORD_RESET_EMAIL_SUBJECT` | `Reset your password` | Email subject |

### Email Template

Customize the reset email in `public/templates/emails/password-reset.html`:

```html
{% extends "emails/base.html" %}

{% block content %}
<h1>Reset Your Password</h1>
<p>Hi {{ user.name }},</p>
<p>Click the button below to reset your password:</p>
<a href="{{ reset_url }}" class="button">Reset Password</a>
<p>This link expires in {{ expiry_minutes }} minutes.</p>
{% endblock %}
```

## Admin Password Reset

### Reset via Dashboard

1. Navigate to **Admin Dashboard** → **Users**
2. Select the user
3. Click **Reset Password**
4. Choose:
   - **Send Reset Email** - User receives email
   - **Set Password** - Admin sets new password

### Reset via API

#### Send Reset Email

```bash
POST /api/users/{id}/send-password-reset
Authorization: Bearer {admin_token}
```

#### Set Password Directly

```bash
PATCH /api/users/{id}
Content-Type: application/json
Authorization: Bearer {admin_token}

{
  "password": "NewSecurePassword123"
}
```

{% hint style="warning" %}
Setting passwords directly should notify the user.
{% endhint %}

## Security Considerations

### Rate Limiting

Prevent abuse of reset endpoint:

```bash
PASSWORD_RESET_RATE_LIMIT=3
PASSWORD_RESET_RATE_WINDOW=3600
```

This allows 3 reset requests per hour per email.

### Token Security

Reset tokens are:

- Single-use
- Time-limited
- Cryptographically random
- Invalidated on password change

### Email Enumeration Protection

Don't reveal if email exists:

```bash
HIDE_EMAIL_EXISTENCE=true
```

Response is always:

```
If an account with that email exists, a reset link has been sent.
```

## Audit Trail

Password reset events are logged:

| Event | Description |
|-------|-------------|
| `password.reset_requested` | Reset email requested |
| `password.reset_sent` | Reset email sent |
| `password.reset_completed` | Password was reset |
| `password.reset_failed` | Reset attempt failed |

## Customization

### Reset Page Styling

Customize `public/templates/reset-password.html`:

```html
{% extends "layout.html" %}
{% set title = "Reset Password" %}

{% block body %}
<main class="reset-form">
  <h1>Choose a New Password</h1>
  <form action="/reset-password" method="post">
    <input type="hidden" name="token" value="{{ token }}">
    <input type="password" name="password" placeholder="New Password" required>
    <input type="password" name="password_confirmation" placeholder="Confirm Password" required>
    <button type="submit">Reset Password</button>
  </form>
</main>
{% endblock %}
```

### Success Page

After successful reset, show:

```html
<h1>Password Reset Complete</h1>
<p>Your password has been updated.</p>
<a href="/signin">Sign In</a>
```

## Troubleshooting

### Email Not Received

- Check spam folder
- Verify email configuration
- Check logs for sending errors
- Confirm email address is correct

### Token Expired

- Request new reset link
- Check `PASSWORD_RESET_TTL` setting

### Password Not Accepted

- Verify password meets policy requirements
- Check password history restrictions

## Integration

### Custom Reset Flow

For custom applications:

```javascript
// Request reset
const response = await fetch('/api/password-reset', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ email: 'user@example.com' })
});

// Complete reset
const response = await fetch('/api/password-reset/complete', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    token: 'reset_token_from_email',
    password: 'NewPassword123'
  })
});
```

## Next Steps

- [Create Admin](create-admin.md) - Admin accounts
- [Manage Sessions](manage-sessions.md) - Session management
- [Password Policies](../security/password-policies.md) - Password requirements
