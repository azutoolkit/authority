# Configure Sign in with Apple

Enable users to sign in with their Apple ID.

## Prerequisites

- Authority instance running
- Admin access to Authority dashboard
- Apple Developer account ($99/year membership required)

## Overview

Apple Sign-In is more complex than other providers because:

1. Uses JWT-based client authentication (not simple client secret)
2. Requires Apple Developer Program membership
3. Has strict UI requirements
4. Offers email relay for privacy

## Step 1: Create App ID

1. Go to [Apple Developer Console](https://developer.apple.com/)

2. Navigate to **Certificates, Identifiers & Profiles**

3. Click **Identifiers** > **+** button

4. Select **App IDs** > **Continue**

5. Select **App** type > **Continue**

6. Fill in details:
   - **Description:** Your app name
   - **Bundle ID:** com.yourcompany.yourapp (explicit, not wildcard)

7. In Capabilities, enable **Sign in with Apple**

8. Click **Continue** > **Register**

## Step 2: Create Services ID

1. Click **Identifiers** > **+** button

2. Select **Services IDs** > **Continue**

3. Fill in details:
   - **Description:** Your service description
   - **Identifier:** com.yourcompany.yourapp.auth (this is your Client ID)

4. Click **Continue** > **Register**

5. Click on your new Services ID to configure:
   - Enable **Sign in with Apple**
   - Click **Configure**

6. In configuration:
   - **Primary App ID:** Select your App ID from Step 1
   - **Domains:** your-authority-domain (without https://)
   - **Return URLs:** `https://your-authority-domain/auth/apple/callback`
   - Click **Save**

## Step 3: Create Private Key

1. Navigate to **Keys** > **+** button

2. Fill in details:
   - **Key Name:** Authority Sign-in Key
   - Enable **Sign in with Apple**
   - Click **Configure** and select your Primary App ID

3. Click **Continue** > **Register**

4. **Download the key file** (.p8) - you can only download it once!

5. Note the **Key ID** displayed

## Step 4: Get Your Team ID

Find your Team ID:
- Go to **Membership** in Apple Developer Console
- Your **Team ID** is displayed (10-character string)

## Step 5: Configure Authority

You need four pieces of information:

| Setting | Where to Find |
|---------|---------------|
| Client ID | Services ID identifier (e.g., com.yourcompany.yourapp.auth) |
| Team ID | Membership page in Developer Console |
| Key ID | Shown when creating the key |
| Private Key | Contents of the .p8 file |

### Using Admin Dashboard

1. Log in to Authority admin dashboard
2. Navigate to **Settings** > **Social Login**
3. Enable **Apple OAuth**
4. Enter your credentials:
   - Client ID: Your Services ID identifier
   - Team ID: Your Apple Team ID
   - Key ID: Your key identifier
   - Private Key: Paste contents of .p8 file (including BEGIN/END lines)
5. Save settings

### Using Environment Variables

```bash
APPLE_OAUTH_ENABLED=true
APPLE_CLIENT_ID=com.yourcompany.yourapp.auth
APPLE_TEAM_ID=XXXXXXXXXX
APPLE_KEY_ID=XXXXXXXXXX
APPLE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----
MIGTAgEA...
-----END PRIVATE KEY-----"
```

{% hint style="warning" %}
Keep your private key secure. Never commit it to version control.
{% endhint %}

## Step 6: Add Login Button

Apple has specific requirements for their button:

```html
<a href="https://your-authority-domain/auth/apple" class="btn-apple">
  <svg><!-- Apple logo --></svg>
  Sign in with Apple
</a>
```

See [Apple's Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/sign-in-with-apple) for button requirements.

## User Data Retrieved

| Field | Description |
|-------|-------------|
| `sub` | Unique Apple user ID |
| `email` | User's email (real or relay) |
| `email_verified` | Always true for Apple |
| `name` | Name (only on first auth) |

{% hint style="info" %}
Apple only provides the user's name on the **first** authentication. Store it immediately.
{% endhint %}

## Email Relay

Users can choose to hide their real email. Apple provides a relay address like:
```
abc123@privaterelay.appleid.com
```

Emails sent to this address are forwarded to the user's real email.

To send emails to relay addresses:
1. Register your email domains in Apple Developer Console
2. Configure SPF/DKIM for your sending domain

## Troubleshooting

### "Invalid client_id"

Services ID not configured correctly.

**Solution:**
- Verify Services ID identifier matches your Client ID
- Ensure Sign in with Apple is enabled on the Services ID
- Check domain and return URL configuration

### "Invalid redirect_uri"

Callback URL not registered.

**Solution:**
- In Services ID configuration, verify Return URL exactly matches:
  ```
  https://your-authority-domain/auth/apple/callback
  ```
- Ensure domain is registered (without https://)

### "Invalid grant"

Authorization code expired or already used.

**Solution:** Apple codes expire quickly. Ensure your token exchange happens promptly.

### Name Not Retrieved

Apple only provides name on first authentication.

**Solution:** Store the name immediately on first login. If missed, user must revoke app access and re-authenticate.

## Security Considerations

1. **Protect your private key** - Store securely, never in code
2. **Rotate keys periodically** - Create new key, update config, then delete old key
3. **Handle relay emails** - Test email delivery to relay addresses
4. **First-auth data** - Cache name immediately as it's only provided once

## Next Steps

- [Configure Google](configure-google.md) - Simpler provider setup
- [Manage Linked Accounts](manage-linked-accounts.md) - Account linking
