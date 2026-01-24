# Audit Logging

Track all security-relevant actions in Authority.

## Overview

Authority logs all significant events to help with:

- Security monitoring
- Compliance requirements
- Incident investigation
- User activity tracking

## Logged Events

| Event | Description |
|-------|-------------|
| `user.login` | Successful login |
| `user.login_failed` | Failed login attempt |
| `user.logout` | User logout |
| `user.created` | New user registration |
| `user.updated` | Profile update |
| `user.deleted` | User deletion |
| `user.locked` | Account locked |
| `user.unlocked` | Account unlocked |
| `mfa.enabled` | MFA enabled |
| `mfa.disabled` | MFA disabled |
| `password.changed` | Password change |
| `password.reset` | Password reset request |
| `token.issued` | Token issued |
| `token.revoked` | Token revocation |
| `client.created` | OAuth client created |
| `client.updated` | OAuth client updated |
| `client.deleted` | OAuth client deleted |
| `scope.created` | Scope created |
| `scope.updated` | Scope updated |
| `authorization.granted` | User granted authorization |
| `authorization.denied` | User denied authorization |

## Log Entry Format

Each log entry includes:

| Field | Description |
|-------|-------------|
| `id` | Unique log entry ID |
| `timestamp` | When the event occurred |
| `event` | Event type |
| `actor_id` | User or client who performed action |
| `actor_type` | `user`, `client`, or `system` |
| `resource_type` | Type of resource affected |
| `resource_id` | ID of affected resource |
| `ip_address` | Client IP address |
| `user_agent` | Browser/client information |
| `metadata` | Additional event-specific data |

Example entry:

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "timestamp": "2024-01-15T10:30:00Z",
  "event": "user.login",
  "actor_id": "user-uuid",
  "actor_type": "user",
  "resource_type": "session",
  "resource_id": "session-uuid",
  "ip_address": "192.168.1.100",
  "user_agent": "Mozilla/5.0...",
  "metadata": {
    "method": "password",
    "mfa_used": true
  }
}
```

## Viewing Logs

### Admin Dashboard

1. Navigate to **Admin Dashboard** → **Audit Logs**
2. Use filters to find specific events

![Audit Logs](../../screenshots/admin-audit-logs.gif)

### Filter Options

- **Date range** - Start and end dates
- **Event type** - Filter by specific event
- **User** - Filter by actor
- **Resource** - Filter by affected resource
- **IP address** - Filter by source IP

### Export

Export logs in various formats:

- **CSV** - For spreadsheet analysis
- **JSON** - For processing with scripts
- **PDF** - For reports

## API Access

### List Logs

```bash
GET /api/audit-logs?limit=100&offset=0
Authorization: Bearer {admin_token}
```

Response:
```json
{
  "data": [
    {
      "id": "...",
      "timestamp": "2024-01-15T10:30:00Z",
      "event": "user.login",
      ...
    }
  ],
  "total": 1250,
  "limit": 100,
  "offset": 0
}
```

### Filter Logs

```bash
GET /api/audit-logs?event=user.login_failed&from=2024-01-01&to=2024-01-31
Authorization: Bearer {admin_token}
```

### Get Single Entry

```bash
GET /api/audit-logs/{id}
Authorization: Bearer {admin_token}
```

## Log Retention

### Configuration

```bash
# Retain logs for 90 days
AUDIT_LOG_RETENTION_DAYS=90

# Run cleanup daily
AUDIT_LOG_CLEANUP_SCHEDULE=0 2 * * *
```

### Manual Cleanup

```bash
crystal run src/tasks/cleanup_audit_logs.cr
```

## External Log Shipping

### Syslog

```bash
AUDIT_LOG_SYSLOG=true
SYSLOG_HOST=logs.example.com
SYSLOG_PORT=514
```

### File Output

```bash
AUDIT_LOG_FILE=/var/log/authority/audit.log
AUDIT_LOG_FORMAT=json
```

### SIEM Integration

Export logs to security information systems:

```bash
# Splunk
AUDIT_LOG_SPLUNK_URL=https://splunk.example.com:8088
AUDIT_LOG_SPLUNK_TOKEN=your-hec-token

# Elasticsearch
AUDIT_LOG_ELASTICSEARCH_URL=https://elasticsearch.example.com:9200
AUDIT_LOG_ELASTICSEARCH_INDEX=authority-audit
```

## Monitoring and Alerting

### Failed Login Alerts

```bash
# Alert after 10 failed logins in 5 minutes
grep "user.login_failed" /var/log/authority/audit.log | \
  awk -v d="$(date -d '5 minutes ago' +%Y-%m-%dT%H:%M)" '$2 > d' | \
  wc -l | \
  xargs -I {} sh -c '[ {} -gt 10 ] && echo "Alert: High failed logins"'
```

### Suspicious Activity

Monitor for:

- Multiple failed logins from same IP
- Admin account logins from new IPs
- MFA disabled events
- Client secret rotations

## Compliance

### GDPR

Audit logs help demonstrate:

- Who accessed user data
- What changes were made
- When access occurred

### SOC 2

Logs provide evidence of:

- Access controls
- Monitoring activities
- Incident response

## Best Practices

{% hint style="info" %}
- Enable log shipping to external systems
- Retain logs for at least 90 days
- Set up alerts for critical events
- Regularly review logs for anomalies
{% endhint %}

{% hint style="warning" %}
- Don't log sensitive data (passwords, tokens)
- Protect log access with strong controls
- Consider log integrity (tampering detection)
{% endhint %}

## Next Steps

- [Enable MFA](enable-mfa.md) - Multi-factor authentication
- [Account Lockout](configure-lockout.md) - Brute-force protection
- [Password Policies](password-policies.md) - Password requirements
