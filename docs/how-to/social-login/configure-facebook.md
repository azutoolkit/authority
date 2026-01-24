# Configure Facebook Login

Enable users to sign in with their Facebook accounts.

## Prerequisites

- Authority instance running
- Admin access to Authority dashboard
- Facebook Developer account

## Step 1: Create Facebook App

1. Go to [Facebook Developers](https://developers.facebook.com/)

2. Click **My Apps** > **Create App**

3. Select app type:
   - Choose **Consumer** or **Business** depending on your use case
   - Click **Next**

4. Fill in app details:
   - **App name:** Your application name
   - **App contact email:** Your email
   - Click **Create App**

5. Add Facebook Login product:
   - Find **Facebook Login** in products
   - Click **Set Up**
   - Choose **Web**
   - Enter your site URL

6. Configure OAuth settings:
   - Go to **Facebook Login** > **Settings**
   - Add to **Valid OAuth Redirect URIs:**
     ```
     https://your-authority-domain/auth/facebook/callback
     ```
   - Save changes

7. Get credentials:
   - Go to **Settings** > **Basic**
   - Copy **App ID** and **App Secret**

## Step 2: Configure Authority

### Using Admin Dashboard

1. Log in to Authority admin dashboard
2. Navigate to **Settings** > **Social Login**
3. Enable **Facebook OAuth**
4. Enter your credentials:
   - Client ID: Your Facebook App ID
   - Client Secret: Your Facebook App Secret
5. Save settings

### Using Environment Variables

```bash
FACEBOOK_OAUTH_ENABLED=true
FACEBOOK_CLIENT_ID=your-facebook-app-id
FACEBOOK_CLIENT_SECRET=your-facebook-app-secret
```

## Step 3: Add Login Button

```html
<a href="https://your-authority-domain/auth/facebook" class="btn-facebook">
  <svg><!-- Facebook icon --></svg>
  Continue with Facebook
</a>
```

With forward URL:

```javascript
const forwardUrl = btoa('https://your-app.com/dashboard');
const facebookAuthUrl = `https://your-authority-domain/auth/facebook?forward_url=${forwardUrl}`;
```

## Step 4: App Review (Production)

For production use, you need to:

1. **Complete Data Use Checkup** - Explain how you use user data
2. **Add Privacy Policy URL** - Required for public apps
3. **Submit for App Review** - If requesting advanced permissions

For basic login (email + public_profile), you may not need full review.

## User Data Retrieved

| Field | Description |
|-------|-------------|
| `id` | Facebook user ID |
| `email` | User's email (if permitted) |
| `name` | Full name |
| `picture` | Profile picture URL |

## Troubleshooting

### "App Not Active"

Your Facebook app is in development mode.

**Solution:**
- In development mode, only app admins/developers/testers can log in
- Add test users in **Roles** section
- Or switch to Live mode after review

### "URL Blocked"

Redirect URI isn't whitelisted.

**Solution:** Add the exact callback URL to Valid OAuth Redirect URIs:
```
https://your-authority-domain/auth/facebook/callback
```

### No Email Retrieved

User may have signed up with phone number or denied email permission.

**Solution:** Handle missing email gracefully in your application.

### "Invalid Scopes"

Requested scopes not approved for your app.

**Solution:**
- For `email` and `public_profile`, no review needed
- Advanced scopes require App Review

## Privacy Considerations

Facebook has strict data usage policies:

- Only request data you need
- Explain data usage in your privacy policy
- Delete user data upon request
- Complete annual Data Use Checkup

## Next Steps

- [Configure Google](configure-google.md) - Add Google sign-in
- [Manage Linked Accounts](manage-linked-accounts.md) - Account linking
