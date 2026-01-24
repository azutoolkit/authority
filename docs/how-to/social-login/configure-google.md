# Configure Google Sign-In

Enable users to sign in with their Google accounts.

## Prerequisites

- Authority instance running
- Admin access to Authority dashboard
- Google Cloud Console account

## Step 1: Create Google OAuth App

1. Go to [Google Cloud Console](https://console.cloud.google.com/)

2. Create a new project or select existing one

3. Navigate to **APIs & Services** > **Credentials**

4. Click **Create Credentials** > **OAuth client ID**

5. If prompted, configure the OAuth consent screen:
   - Choose **External** for public apps or **Internal** for organization-only
   - Fill in app name, user support email, and developer contact
   - Add scopes: `email`, `profile`, `openid`
   - Add test users if in testing mode

6. For OAuth client ID:
   - Application type: **Web application**
   - Name: Your app name
   - Authorized redirect URIs: `https://your-authority-domain/auth/google/callback`

7. Save your **Client ID** and **Client Secret**

## Step 2: Configure Authority

### Using Admin Dashboard

1. Log in to Authority admin dashboard
2. Navigate to **Settings** > **Social Login**
3. Enable **Google OAuth**
4. Enter your credentials:
   - Client ID: `your-google-client-id.apps.googleusercontent.com`
   - Client Secret: `your-google-client-secret`
5. Save settings

### Using Environment Variables

```bash
GOOGLE_OAUTH_ENABLED=true
GOOGLE_CLIENT_ID=your-client-id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your-client-secret
```

## Step 3: Add Login Button

Add a Google sign-in button to your application:

```html
<a href="https://your-authority-domain/auth/google" class="btn-google">
  <svg><!-- Google icon --></svg>
  Sign in with Google
</a>
```

With forward URL (redirect after login):

```html
<a href="https://your-authority-domain/auth/google?forward_url=BASE64_ENCODED_URL">
  Sign in with Google
</a>
```

```javascript
const forwardUrl = btoa('https://your-app.com/dashboard');
const googleAuthUrl = `https://your-authority-domain/auth/google?forward_url=${forwardUrl}`;
```

## Step 4: Test the Integration

1. Click your Google sign-in button
2. You should be redirected to Google's consent page
3. After approving, you'll be redirected back to Authority
4. A new user account is created (or existing account linked)
5. You're redirected to your application

## User Data Retrieved

Authority fetches the following from Google:

| Field | Description |
|-------|-------------|
| `sub` | Unique Google user ID |
| `email` | User's email address |
| `email_verified` | Whether email is verified |
| `name` | Full name |
| `given_name` | First name |
| `family_name` | Last name |
| `picture` | Profile picture URL |

## Troubleshooting

### "redirect_uri_mismatch" Error

The callback URL doesn't match what's configured in Google Console.

**Solution:** Ensure the redirect URI in Google Console exactly matches:
```
https://your-authority-domain/auth/google/callback
```

### "Access blocked: App not verified"

Your app is in testing mode and the user isn't a test user.

**Solution:** Either:
- Add the user as a test user in Google Console
- Submit your app for verification (production)

### "Invalid client" Error

The client ID or secret is incorrect.

**Solution:**
- Verify credentials in Authority settings
- Check for extra spaces or characters
- Regenerate secret if needed

### User Not Created

Check Authority logs for errors. Common issues:
- Email already exists with different provider
- Database connection issues
- Missing required scopes

## Security Best Practices

1. **Verify emails** - Google provides `email_verified` claim
2. **Use HTTPS** - Required for OAuth callbacks
3. **Restrict domains** - In Google Console, you can restrict to your domain
4. **Review permissions** - Only request scopes you need
5. **Monitor usage** - Check Google Console for suspicious activity

## Next Steps

- [Configure GitHub](configure-github.md) - Add another provider
- [Manage Linked Accounts](manage-linked-accounts.md) - Account linking
- [Enable MFA](../security/enable-mfa.md) - Add extra security
