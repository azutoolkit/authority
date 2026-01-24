# Security Settings

Configuration options for Authority security features.

## Account Lockout

| Variable | Default | Description |
|----------|---------|-------------|
| `LOCKOUT_THRESHOLD` | `5` | Failed attempts before lockout |
| `LOCKOUT_DURATION` | `30` | Lockout duration (minutes) |
| `ENABLE_AUTO_UNLOCK` | `true` | Auto-unlock after duration |
| `PROGRESSIVE_LOCKOUT` | `false` | Increase duration with each lockout |
| `LOCKOUT_BY_IP` | `false` | Lock by IP instead of account |
| `IP_LOCKOUT_THRESHOLD` | `10` | IP-based lockout threshold |
| `LOCKOUT_WHITELIST` | | IPs exempt from lockout |

## Password Policies

| Variable | Default | Description |
|----------|---------|-------------|
| `PASSWORD_MIN_LENGTH` | `12` | Minimum password length |
| `PASSWORD_HISTORY_COUNT` | `5` | Prevent password reuse |
| `PASSWORD_EXPIRY_DAYS` | `0` | Password expiration (0=never) |
| `PASSWORD_EXPIRY_WARNING_DAYS` | `14` | Warn before expiry |
| `PASSWORD_EXPIRY_GRACE_DAYS` | `7` | Grace period |
| `REQUIRE_UPPERCASE` | `true` | Require uppercase |
| `REQUIRE_LOWERCASE` | `true` | Require lowercase |
| `REQUIRE_NUMBERS` | `true` | Require numbers |
| `REQUIRE_SPECIAL` | `false` | Require special chars |
| `CHECK_COMMON_PASSWORDS` | `false` | Check against list |
| `COMMON_PASSWORD_LIST` | | Path to password list |

## Admin Password Policies

| Variable | Default | Description |
|----------|---------|-------------|
| `ADMIN_PASSWORD_MIN_LENGTH` | `16` | Admin minimum length |
| `ADMIN_PASSWORD_EXPIRY_DAYS` | `30` | Admin expiration |

## Multi-Factor Authentication

| Variable | Default | Description |
|----------|---------|-------------|
| `REQUIRE_MFA` | `false` | Require MFA for all users |
| `REQUIRE_ADMIN_MFA` | `true` | Require MFA for admins |
| `MFA_GRACE_PERIOD_DAYS` | `7` | Time to set up MFA |

## Session Security

| Variable | Default | Description |
|----------|---------|-------------|
| `SESSION_DURATION_DAYS` | `7` | Maximum session lifetime |
| `IDLE_TIMEOUT_MINUTES` | `30` | Idle timeout |
| `SINGLE_SESSION` | `false` | Only one active session |
| `NOTIFY_NEW_SESSION` | `false` | Email on new login |
| `REVOKE_TOKENS_ON_SESSION_END` | `true` | Revoke tokens on logout |

## Access Control

| Variable | Default | Description |
|----------|---------|-------------|
| `ADMIN_ALLOWED_IPS` | | IP whitelist for admin |
| `HIDE_EMAIL_EXISTENCE` | `true` | Don't reveal if email exists |

## Password Reset

| Variable | Default | Description |
|----------|---------|-------------|
| `PASSWORD_RESET_TTL` | `3600` | Reset token lifetime (seconds) |
| `PASSWORD_RESET_RATE_LIMIT` | `3` | Max resets per window |
| `PASSWORD_RESET_RATE_WINDOW` | `3600` | Rate limit window (seconds) |

## JWT Security

| Variable | Default | Description |
|----------|---------|-------------|
| `SECRET_KEY` | Required | JWT signing key |
| `JWT_ALGORITHM` | `RS256` | Signing algorithm |

## Audit Logging

| Variable | Default | Description |
|----------|---------|-------------|
| `AUDIT_LOG_RETENTION_DAYS` | `90` | Log retention period |
| `AUDIT_LOG_SYSLOG` | `false` | Send to syslog |
| `SYSLOG_HOST` | | Syslog server |
| `SYSLOG_PORT` | `514` | Syslog port |

## Example: High Security

```bash
# Strict account lockout
LOCKOUT_THRESHOLD=3
LOCKOUT_DURATION=60
PROGRESSIVE_LOCKOUT=true

# Strong passwords
PASSWORD_MIN_LENGTH=16
REQUIRE_UPPERCASE=true
REQUIRE_LOWERCASE=true
REQUIRE_NUMBERS=true
REQUIRE_SPECIAL=true
PASSWORD_EXPIRY_DAYS=90
CHECK_COMMON_PASSWORDS=true

# MFA required
REQUIRE_MFA=true
REQUIRE_ADMIN_MFA=true

# Short sessions
SESSION_DURATION_DAYS=1
IDLE_TIMEOUT_MINUTES=15
SINGLE_SESSION=true

# Notifications
NOTIFY_NEW_SESSION=true

# IP restrictions
ADMIN_ALLOWED_IPS=10.0.0.0/8
```

## Example: User-Friendly

```bash
# Lenient lockout
LOCKOUT_THRESHOLD=10
LOCKOUT_DURATION=15
ENABLE_AUTO_UNLOCK=true

# Reasonable passwords
PASSWORD_MIN_LENGTH=10
REQUIRE_UPPERCASE=false
REQUIRE_LOWERCASE=false
REQUIRE_NUMBERS=false
PASSWORD_EXPIRY_DAYS=0

# MFA optional except admins
REQUIRE_MFA=false
REQUIRE_ADMIN_MFA=true

# Longer sessions
SESSION_DURATION_DAYS=30
IDLE_TIMEOUT_MINUTES=60
```

## Next Steps

- [Token Settings](token-settings.md) - Token configuration
- [All Options](all-options.md) - Complete reference
- [Enable MFA](../../how-to/security/enable-mfa.md) - MFA setup
