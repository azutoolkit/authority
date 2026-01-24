# Password Policies

Configure password requirements for Authority users.

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PASSWORD_MIN_LENGTH` | `12` | Minimum password length |
| `PASSWORD_HISTORY_COUNT` | `5` | Prevent reuse of recent passwords |
| `PASSWORD_EXPIRY_DAYS` | `0` | Days until password expires (0 = never) |
| `REQUIRE_UPPERCASE` | `true` | Require uppercase letters |
| `REQUIRE_LOWERCASE` | `true` | Require lowercase letters |
| `REQUIRE_NUMBERS` | `true` | Require numeric digits |
| `REQUIRE_SPECIAL` | `false` | Require special characters |

## Example Configurations

### Standard Security

```bash
PASSWORD_MIN_LENGTH=12
REQUIRE_UPPERCASE=true
REQUIRE_LOWERCASE=true
REQUIRE_NUMBERS=true
REQUIRE_SPECIAL=false
PASSWORD_HISTORY_COUNT=5
PASSWORD_EXPIRY_DAYS=0
```

### High Security

```bash
PASSWORD_MIN_LENGTH=16
REQUIRE_UPPERCASE=true
REQUIRE_LOWERCASE=true
REQUIRE_NUMBERS=true
REQUIRE_SPECIAL=true
PASSWORD_HISTORY_COUNT=12
PASSWORD_EXPIRY_DAYS=90
```

### User-Friendly

```bash
PASSWORD_MIN_LENGTH=10
REQUIRE_UPPERCASE=false
REQUIRE_LOWERCASE=false
REQUIRE_NUMBERS=false
REQUIRE_SPECIAL=false
PASSWORD_HISTORY_COUNT=3
PASSWORD_EXPIRY_DAYS=0
```

## Password Validation

When a user sets a password, Authority validates:

1. **Length** - Meets minimum requirement
2. **Complexity** - Contains required character types
3. **History** - Not recently used
4. **Strength** - Not in common password lists (optional)

### Validation Messages

Users see clear feedback:

```
Password must:
✗ Be at least 12 characters
✓ Contain an uppercase letter
✓ Contain a lowercase letter
✗ Contain a number
```

## Password Expiry

When `PASSWORD_EXPIRY_DAYS` is set, users must change passwords periodically.

### Expiry Warning

Users are warned before expiry:

```bash
PASSWORD_EXPIRY_WARNING_DAYS=14
```

### Grace Period

Allow logins during grace period:

```bash
PASSWORD_EXPIRY_GRACE_DAYS=7
```

### Handling Expired Passwords

When a password expires:

1. User logs in with expired password
2. Authority forces password change
3. User cannot access application until password is changed

## Password History

Prevent password reuse:

```bash
# Remember last 5 passwords
PASSWORD_HISTORY_COUNT=5
```

If a user tries to reuse a password:

```
This password was used recently. Please choose a different password.
```

## Common Password Check

Block commonly used passwords:

```bash
CHECK_COMMON_PASSWORDS=true
COMMON_PASSWORD_LIST=/path/to/passwords.txt
```

Download a password list:

```bash
wget https://github.com/danielmiessler/SecLists/raw/master/Passwords/Common-Credentials/10k-most-common.txt -O passwords.txt
```

## API Integration

### Validate Password

```bash
POST /api/validate-password
Content-Type: application/json

{
  "password": "MyNewPassword123"
}
```

Response:
```json
{
  "valid": false,
  "errors": [
    "Password must contain a special character"
  ]
}
```

### Check Password Expiry

```bash
GET /api/users/{id}/password-status
Authorization: Bearer {token}
```

Response:
```json
{
  "last_changed": "2024-01-01T00:00:00Z",
  "expires_at": "2024-04-01T00:00:00Z",
  "days_until_expiry": 45,
  "requires_change": false
}
```

## User Experience

### Password Strength Indicator

The UI shows password strength in real-time:

- **Weak** - Red, doesn't meet requirements
- **Fair** - Yellow, meets minimum
- **Strong** - Green, exceeds requirements

### Password Generator

Offer a password generator:

```javascript
function generatePassword(length = 16) {
  const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*';
  let password = '';
  for (let i = 0; i < length; i++) {
    password += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return password;
}
```

## Best Practices

{% hint style="success" %}
**Modern recommendations (NIST SP 800-63B):**

- Focus on length over complexity
- Allow spaces and all printable characters
- Check against breach databases
- Avoid forced periodic rotation
{% endhint %}

{% hint style="warning" %}
**Avoid:**

- Very short minimum lengths (< 8)
- Forced rotation without reason
- Overly complex rules that encourage weak patterns
{% endhint %}

## Troubleshooting

### Password rejected unexpectedly

- Check which rules are enabled
- Verify character encoding
- Review password history

### Users forgetting complex passwords

- Consider reducing complexity requirements
- Enable password manager hints
- Implement "forgot password" flow

## Next Steps

- [Enable MFA](enable-mfa.md) - Multi-factor authentication
- [Account Lockout](configure-lockout.md) - Brute-force protection
- [Audit Logging](audit-logging.md) - Track security events
