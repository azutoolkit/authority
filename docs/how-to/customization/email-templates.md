# Customize Email Templates

Configure transactional emails sent by Authority.

## Email Types

Authority sends these transactional emails:

| Email | Trigger |
|-------|---------|
| **Welcome** | New user registration |
| **Email Verification** | Verify email address |
| **Password Reset** | Reset password request |
| **MFA Enabled** | Two-factor authentication enabled |
| **New Login** | Login from new device |

## Template Location

```
public/templates/emails/
├── base.html           # Base layout
├── welcome.html        # Welcome email
├── verification.html   # Email verification
├── password-reset.html # Password reset
├── mfa-enabled.html    # MFA confirmation
└── new-login.html      # New login alert
```

## Template Structure

### Base Template

`emails/base.html`:

```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      line-height: 1.6;
      color: #333;
      max-width: 600px;
      margin: 0 auto;
      padding: 20px;
    }
    .header {
      text-align: center;
      margin-bottom: 30px;
    }
    .logo {
      max-width: 150px;
    }
    .button {
      display: inline-block;
      padding: 12px 24px;
      background-color: #7c3aed;
      color: white;
      text-decoration: none;
      border-radius: 6px;
      margin: 20px 0;
    }
    .footer {
      margin-top: 40px;
      padding-top: 20px;
      border-top: 1px solid #eee;
      font-size: 12px;
      color: #666;
    }
  </style>
</head>
<body>
  <div class="header">
    <img src="{{ base_url }}/images/logo.png" alt="Authority" class="logo">
  </div>

  {% block content %}{% endblock %}

  <div class="footer">
    <p>This email was sent by {{ app_name }}.</p>
    <p>{{ company_address }}</p>
  </div>
</body>
</html>
```

### Password Reset Email

`emails/password-reset.html`:

```html
{% extends "emails/base.html" %}

{% block content %}
<h1>Reset Your Password</h1>

<p>Hi {{ user.name }},</p>

<p>We received a request to reset your password. Click the button below to choose a new password:</p>

<p style="text-align: center;">
  <a href="{{ reset_url }}" class="button">Reset Password</a>
</p>

<p>This link will expire in {{ expiry_minutes }} minutes.</p>

<p>If you didn't request a password reset, you can safely ignore this email. Your password won't be changed.</p>

<p>
  Best regards,<br>
  The {{ app_name }} Team
</p>
{% endblock %}
```

### Welcome Email

`emails/welcome.html`:

```html
{% extends "emails/base.html" %}

{% block content %}
<h1>Welcome to {{ app_name }}!</h1>

<p>Hi {{ user.name }},</p>

<p>Thanks for creating an account. We're excited to have you on board!</p>

<p>Here are a few things you can do:</p>

<ul>
  <li>Complete your profile</li>
  <li>Enable two-factor authentication</li>
  <li>Connect your applications</li>
</ul>

<p style="text-align: center;">
  <a href="{{ profile_url }}" class="button">View Your Profile</a>
</p>

<p>
  Welcome aboard,<br>
  The {{ app_name }} Team
</p>
{% endblock %}
```

## Available Variables

### All Emails

| Variable | Description |
|----------|-------------|
| `base_url` | Authority base URL |
| `app_name` | Application name |
| `company_address` | Company address |
| `user.name` | User's name |
| `user.email` | User's email |

### Password Reset

| Variable | Description |
|----------|-------------|
| `reset_url` | Password reset link |
| `expiry_minutes` | Link expiry time |

### Email Verification

| Variable | Description |
|----------|-------------|
| `verification_url` | Verification link |
| `expiry_hours` | Link expiry time |

### New Login Alert

| Variable | Description |
|----------|-------------|
| `device` | Device description |
| `location` | Approximate location |
| `ip_address` | Client IP |
| `login_time` | Login timestamp |

## Configuration

### SMTP Settings

```bash
SMTP_HOST=smtp.example.com
SMTP_PORT=587
SMTP_USER=notifications@example.com
SMTP_PASSWORD=your_password
SMTP_FROM=noreply@example.com
SMTP_FROM_NAME=Authority
```

### Email Settings

```bash
EMAIL_VERIFICATION_REQUIRED=true
EMAIL_VERIFICATION_TTL=86400
PASSWORD_RESET_TTL=3600
```

## Testing Emails

### Preview in Browser

```bash
# Development mode shows emails in browser
CRYSTAL_ENV=development
EMAIL_PREVIEW=true
```

### Send Test Email

```bash
crystal run src/tasks/send_test_email.cr -- \
  --to test@example.com \
  --template password-reset
```

## HTML Email Best Practices

{% hint style="info" %}
**Email HTML is limited:**

- Use inline CSS
- Use tables for layout
- Avoid JavaScript
- Test across email clients
{% endhint %}

### Compatible Styles

```html
<!-- Use inline styles -->
<p style="color: #333; font-size: 16px;">Text</p>

<!-- Use tables for layout -->
<table width="100%" cellpadding="0" cellspacing="0">
  <tr>
    <td>Content</td>
  </tr>
</table>

<!-- Simple buttons -->
<a href="{{ url }}" style="
  display: inline-block;
  padding: 12px 24px;
  background-color: #7c3aed;
  color: #ffffff;
  text-decoration: none;
">Button</a>
```

## Localization

### Multiple Languages

```
public/templates/emails/
├── en/
│   ├── welcome.html
│   └── password-reset.html
├── es/
│   ├── welcome.html
│   └── password-reset.html
└── fr/
    ├── welcome.html
    └── password-reset.html
```

Configure default locale:

```bash
DEFAULT_LOCALE=en
```

## Troubleshooting

### Emails Not Sending

- Check SMTP configuration
- Verify credentials
- Check spam filters
- Review server logs

### Broken Layout

- Use inline CSS
- Test with email preview tools
- Check image URLs are absolute

### Images Not Loading

- Use absolute URLs
- Host images on accessible server
- Check HTTPS requirements

## Next Steps

- [UI Templates](templates.md) - Customize pages
- [Branding](branding.md) - Logo and colors
- [Environment Variables](../configuration/environment-variables.md) - Email settings
