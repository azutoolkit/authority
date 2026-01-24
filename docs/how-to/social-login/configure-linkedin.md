# Configure LinkedIn Sign-In

Enable users to sign in with their LinkedIn accounts.

## Prerequisites

- Authority instance running
- Admin access to Authority dashboard
- LinkedIn Developer account

## Step 1: Create LinkedIn App

1. Go to [LinkedIn Developers](https://www.linkedin.com/developers/)

2. Click **Create App**

3. Fill in app details:
   - **App name:** Your application name
   - **LinkedIn Page:** Select or create a company page
   - **Privacy policy URL:** Your privacy policy
   - **App logo:** Upload your logo
   - Click **Create app**

4. In the **Auth** tab:
   - Note your **Client ID** and **Client Secret**
   - Add **Authorized redirect URLs:**
     ```
     https://your-authority-domain/auth/linkedin/callback
     ```

5. In the **Products** tab:
   - Request access to **Sign In with LinkedIn using OpenID Connect**
   - This provides `openid`, `profile`, and `email` scopes

## Step 2: Configure Authority

### Using Admin Dashboard

1. Log in to Authority admin dashboard
2. Navigate to **Settings** > **Social Login**
3. Enable **LinkedIn OAuth**
4. Enter your credentials:
   - Client ID: Your LinkedIn Client ID
   - Client Secret: Your LinkedIn Client Secret
5. Save settings

### Using Environment Variables

```bash
LINKEDIN_OAUTH_ENABLED=true
LINKEDIN_CLIENT_ID=your-linkedin-client-id
LINKEDIN_CLIENT_SECRET=your-linkedin-client-secret
```

## Step 3: Add Login Button

```html
<a href="https://your-authority-domain/auth/linkedin" class="btn-linkedin">
  <svg><!-- LinkedIn icon --></svg>
  Sign in with LinkedIn
</a>
```

With forward URL:

```javascript
const forwardUrl = btoa('https://your-app.com/dashboard');
const linkedinAuthUrl = `https://your-authority-domain/auth/linkedin?forward_url=${forwardUrl}`;
```

## User Data Retrieved

| Field | Description |
|-------|-------------|
| `sub` | LinkedIn member ID |
| `email` | User's email address |
| `email_verified` | Email verification status |
| `name` | Full name |
| `given_name` | First name |
| `family_name` | Last name |
| `picture` | Profile picture URL |

## Troubleshooting

### "Invalid redirect_uri"

Callback URL not registered in LinkedIn app.

**Solution:** Add exact URL to Authorized redirect URLs:
```
https://your-authority-domain/auth/linkedin/callback
```

### "Unauthorized scope"

Requested scope not approved for your app.

**Solution:**
- Ensure you've added "Sign In with LinkedIn using OpenID Connect" product
- Wait for product access approval

### "Application not found"

Client ID is incorrect or app is deleted.

**Solution:** Verify Client ID in LinkedIn Developer Console.

## LinkedIn API Versions

Authority uses LinkedIn's OpenID Connect implementation which provides:
- Standard OIDC claims
- Simplified integration
- Better long-term stability

## Next Steps

- [Configure Google](configure-google.md) - Add more providers
- [Manage Linked Accounts](manage-linked-accounts.md) - Account linking
