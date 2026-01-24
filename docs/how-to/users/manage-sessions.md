# Manage Sessions

View and revoke user sessions in Authority.

## Overview

Sessions represent active user logins. Each session tracks:

- Device information
- IP address
- Login time
- Last activity

## User Self-Service

### View Active Sessions

Users can see their sessions in the profile:

1. Click profile name
2. Select **Security Settings**
3. View **Active Sessions**

![User Profile](../../screenshots/user-profile.gif)

### Revoke Session

1. Find the session in the list
2. Click **Revoke**
3. Confirm revocation

The session is immediately invalidated.

## Admin Management

### View User Sessions

```bash
GET /api/users/{id}/sessions
Authorization: Bearer {admin_token}
```

Response:

```json
{
  "data": [
    {
      "id": "session-uuid",
      "created_at": "2024-01-15T10:30:00Z",
      "last_activity": "2024-01-15T14:20:00Z",
      "ip_address": "192.168.1.100",
      "user_agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)...",
      "device": "Chrome on macOS",
      "location": "San Francisco, CA"
    }
  ]
}
```

### Revoke Specific Session

```bash
DELETE /api/sessions/{session_id}
Authorization: Bearer {admin_token}
```

### Revoke All User Sessions

```bash
DELETE /api/users/{id}/sessions
Authorization: Bearer {admin_token}
```

This forces the user to re-authenticate on all devices.

## Session Settings

### Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `SESSION_DURATION_DAYS` | `7` | Maximum session lifetime |
| `IDLE_TIMEOUT_MINUTES` | `30` | Timeout after inactivity |
| `SINGLE_SESSION` | `false` | Allow only one active session |

### Single Session Mode

Force users to have only one active session:

```bash
SINGLE_SESSION=true
```

When enabled, logging in from a new device revokes existing sessions.

### Idle Timeout

End sessions after inactivity:

```bash
IDLE_TIMEOUT_MINUTES=30
```

Users are logged out after 30 minutes of inactivity.

## Session Information

Each session captures:

| Field | Description |
|-------|-------------|
| `ip_address` | Client IP at login |
| `user_agent` | Browser/app information |
| `device` | Parsed device type |
| `location` | Approximate location (if enabled) |
| `created_at` | Login timestamp |
| `last_activity` | Last request timestamp |

## Security Alerts

### Notify on New Session

Email users about new logins:

```bash
NOTIFY_NEW_SESSION=true
```

Email content:

```
New login to your Authority account

Device: Chrome on macOS
Location: San Francisco, CA
Time: January 15, 2024 at 10:30 AM

If this wasn't you, secure your account immediately.
```

### Suspicious Session Detection

Alert on unusual patterns:

- Login from new location
- Multiple simultaneous sessions
- Login outside business hours

## Bulk Session Management

### Revoke All Sessions (System-Wide)

For security incidents:

```bash
crystal run src/tasks/revoke_all_sessions.cr
```

### Revoke by Criteria

```bash
# Revoke sessions older than 30 days
DELETE /api/sessions?older_than=30d
Authorization: Bearer {admin_token}

# Revoke sessions from specific IP
DELETE /api/sessions?ip=192.168.1.100
Authorization: Bearer {admin_token}
```

## Session in OAuth Flow

### Token and Session Relationship

```
User Session
    └── Access Token 1
    └── Access Token 2
    └── Refresh Token 1
```

Revoking a session can optionally revoke associated tokens:

```bash
REVOKE_TOKENS_ON_SESSION_END=true
```

### SSO Session

For single sign-on, a single session can authorize multiple clients.

## Monitoring

### Active Session Count

```bash
GET /api/metrics/sessions
Authorization: Bearer {admin_token}
```

```json
{
  "active_sessions": 1250,
  "sessions_today": 342,
  "unique_users": 890
}
```

### Session Audit Events

| Event | Description |
|-------|-------------|
| `session.created` | New login |
| `session.refreshed` | Session activity |
| `session.revoked` | Session ended |
| `session.expired` | Session timed out |

## Next Steps

- [Create Admin](create-admin.md) - Admin accounts
- [Password Reset](password-reset.md) - Reset passwords
- [Audit Logging](../security/audit-logging.md) - Track sessions
