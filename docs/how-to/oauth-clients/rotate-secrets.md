# Rotate Client Secrets

Manage and rotate OAuth client secrets for security.

## Why Rotate Secrets?

- Secret may have been exposed
- Regular security policy compliance
- Employee departure
- Security audit requirement

## Rotation Methods

### Method 1: Admin Dashboard

1. Navigate to **Admin Dashboard** → **OAuth Clients**
2. Select the client
3. Click **Rotate Secret**
4. Copy the new secret immediately
5. Update your application configuration
6. The old secret is immediately invalidated

### Method 2: API

```bash
POST /register/{client_id}/renew_secret
Authorization: Bearer {admin_token}
```

Response:

```json
{
  "client_id": "abc123def456",
  "client_secret": "new_secret_xyz789",
  "client_secret_expires_at": 0
}
```

## Zero-Downtime Rotation

For production applications, use a two-step rotation:

### Step 1: Add New Secret

Some systems support multiple active secrets. If Authority supports this:

```bash
POST /register/{client_id}/secrets
Authorization: Bearer {admin_token}

{
  "action": "add"
}
```

### Step 2: Update Application

Update your application to use the new secret.

### Step 3: Remove Old Secret

```bash
DELETE /register/{client_id}/secrets/{old_secret_id}
Authorization: Bearer {admin_token}
```

## Rotation Without Dual Secrets

If you must rotate immediately:

### 1. Prepare New Configuration

Have the new secret ready to deploy.

### 2. Rotate Secret

```bash
POST /register/{client_id}/renew_secret
Authorization: Bearer {admin_token}
```

### 3. Deploy Immediately

Update your application within seconds:

```bash
# Example: Update Kubernetes secret
kubectl create secret generic oauth-secret \
  --from-literal=client-secret=NEW_SECRET \
  --dry-run=client -o yaml | kubectl apply -f -

# Rolling restart
kubectl rollout restart deployment/my-app
```

## Automation

### Scheduled Rotation

Create a rotation script:

```bash
#!/bin/bash
# rotate-secrets.sh

CLIENT_ID="abc123def456"
ADMIN_TOKEN="your_admin_token"
AUTHORITY_URL="https://auth.example.com"

# Rotate secret
NEW_SECRET=$(curl -s -X POST \
  "${AUTHORITY_URL}/register/${CLIENT_ID}/renew_secret" \
  -H "Authorization: Bearer ${ADMIN_TOKEN}" \
  | jq -r '.client_secret')

# Update Kubernetes secret
kubectl create secret generic oauth-secret \
  --from-literal=client-secret="${NEW_SECRET}" \
  --dry-run=client -o yaml | kubectl apply -f -

# Restart application
kubectl rollout restart deployment/my-app

# Notify team
echo "Client secret rotated for ${CLIENT_ID}" | \
  slack-notify --channel "#security"
```

### Cron Schedule

```bash
# Rotate quarterly
0 0 1 */3 * /path/to/rotate-secrets.sh
```

## Secret Expiration

Configure secrets to expire automatically:

```bash
CLIENT_SECRET_LIFETIME_DAYS=90
```

Monitor expiring secrets:

```bash
GET /api/clients?secret_expires_before=2024-04-01
Authorization: Bearer {admin_token}
```

## Audit Trail

All secret rotations are logged:

| Event | Description |
|-------|-------------|
| `client.secret_rotated` | Secret was rotated |
| `client.secret_expired` | Secret expired |

Query the audit log:

```bash
GET /api/audit-logs?event=client.secret_rotated&client_id={client_id}
Authorization: Bearer {admin_token}
```

## Notification

Set up alerts for secret events:

```bash
# Notify on rotation
NOTIFY_ON_SECRET_ROTATION=true
NOTIFICATION_WEBHOOK=https://hooks.slack.com/...
```

## Recovery

### Lost Secret

If you lose a client secret:

1. Log into admin dashboard
2. Rotate to generate new secret
3. Update application immediately

### Compromised Secret

If a secret is compromised:

1. Rotate immediately
2. Review audit logs for unauthorized access
3. Revoke any suspicious tokens
4. Update application with new secret

```bash
# Revoke all tokens for client
POST /api/clients/{client_id}/revoke_tokens
Authorization: Bearer {admin_token}
```

## Best Practices

{% hint style="success" %}
**Do:**

- Rotate secrets regularly (quarterly minimum)
- Automate rotation process
- Use secrets management (Vault, AWS Secrets Manager)
- Monitor for secret exposure
{% endhint %}

{% hint style="warning" %}
**Avoid:**

- Storing secrets in code
- Sharing secrets via email/chat
- Long-lived secrets without rotation
- Manual rotation in production
{% endhint %}

## Next Steps

- [Register Client](register-client.md) - Create OAuth clients
- [Configure Scopes](configure-scopes.md) - Access control
- [Audit Logging](../security/audit-logging.md) - Track rotations
