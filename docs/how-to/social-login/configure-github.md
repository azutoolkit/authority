# Configure GitHub Authentication

Enable users to sign in with their GitHub accounts.

## Prerequisites

- Authority instance running
- Admin access to Authority dashboard
- GitHub account

## Step 1: Create GitHub OAuth App

1. Go to [GitHub Developer Settings](https://github.com/settings/developers)

2. Click **OAuth Apps** > **New OAuth App**

3. Fill in the application details:
   - **Application name:** Your app name
   - **Homepage URL:** `https://your-app.com`
   - **Authorization callback URL:** `https://your-authority-domain/auth/github/callback`

4. Click **Register application**

5. On the app page:
   - Copy the **Client ID**
   - Click **Generate a new client secret**
   - Copy the **Client Secret** immediately (shown only once)

## Step 2: Configure Authority

### Using Admin Dashboard

1. Log in to Authority admin dashboard
2. Navigate to **Settings** > **Social Login**
3. Enable **GitHub OAuth**
4. Enter your credentials:
   - Client ID: Your GitHub client ID
   - Client Secret: Your GitHub client secret
5. Save settings

### Using Environment Variables

```bash
GITHUB_OAUTH_ENABLED=true
GITHUB_CLIENT_ID=your-github-client-id
GITHUB_CLIENT_SECRET=your-github-client-secret
```

## Step 3: Add Login Button

```html
<a href="https://your-authority-domain/auth/github" class="btn-github">
  <svg><!-- GitHub icon --></svg>
  Sign in with GitHub
</a>
```

With forward URL:

```javascript
const forwardUrl = btoa('https://your-app.com/dashboard');
const githubAuthUrl = `https://your-authority-domain/auth/github?forward_url=${forwardUrl}`;
```

## Step 4: Test the Integration

1. Click your GitHub sign-in button
2. Authorize the OAuth app on GitHub
3. You'll be redirected back to Authority
4. Account created/linked automatically
5. Redirected to your application

## User Data Retrieved

| Field | Description |
|-------|-------------|
| `id` | Unique GitHub user ID |
| `login` | GitHub username |
| `email` | Primary email (if public or authorized) |
| `name` | Display name |
| `avatar_url` | Profile picture URL |

## GitHub Organizations

To restrict access to specific organizations, you can check membership after authentication in your application logic.

## Troubleshooting

### "Bad credentials" Error

Client ID or secret is incorrect.

**Solution:** Regenerate the client secret in GitHub and update Authority settings.

### No Email Retrieved

GitHub email is private and user didn't authorize email scope.

**Solution:** The `user:email` scope is requested by default. If email is still missing:
- User may not have a verified email on GitHub
- User may have denied email permission

### "Redirect URI mismatch"

Callback URL doesn't match GitHub app configuration.

**Solution:** Ensure exact match:
```
https://your-authority-domain/auth/github/callback
```

## GitHub Enterprise

For GitHub Enterprise Server, contact your administrator about custom OAuth endpoints.

## Next Steps

- [Configure Google](configure-google.md) - Add Google sign-in
- [Manage Linked Accounts](manage-linked-accounts.md) - Link multiple providers
