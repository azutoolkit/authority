# Create Admin User

Create and manage administrator accounts in Authority.

## Admin Capabilities

Administrators can:

- Manage OAuth clients
- Create and edit users
- Configure scopes
- View audit logs
- Modify system settings

## Admin Dashboard

### Create Admin User

1. Navigate to **Admin Dashboard** → **Users**
2. Click **New User**
3. Fill in the form:

| Field | Description |
|-------|-------------|
| **Email** | Admin email address |
| **Name** | Display name |
| **Password** | Initial password |
| **Role** | Select **Administrator** |

4. Click **Create**

![User Management](../../screenshots/admin-users.gif)

### Promote Existing User

1. Navigate to **Users**
2. Select the user
3. Click **Edit**
4. Change **Role** to **Administrator**
5. Click **Save**

## Command Line

### Create Admin via CLI

```bash
crystal run src/tasks/create_admin.cr -- \
  --email admin@example.com \
  --name "Admin User" \
  --password "SecurePassword123"
```

### Using Database Seed

Create admin during initial setup:

```bash
ADMIN_EMAIL=admin@example.com \
ADMIN_PASSWORD=SecurePassword123 \
crystal run src/db/seed.cr
```

## API

### Create Admin via API

```bash
POST /api/users
Content-Type: application/json
Authorization: Bearer {admin_token}

{
  "email": "newadmin@example.com",
  "name": "New Admin",
  "password": "SecurePassword123",
  "role": "admin"
}
```

### Update User Role

```bash
PATCH /api/users/{id}
Content-Type: application/json
Authorization: Bearer {admin_token}

{
  "role": "admin"
}
```

## Admin Roles

| Role | Permissions |
|------|-------------|
| `user` | Profile management, OAuth authorizations |
| `admin` | Full system access |
| `super_admin` | Can create other admins |

### Role Hierarchy

```
super_admin
    └── admin
        └── user
```

## Security Requirements

### MFA for Admins

Require MFA for all admin accounts:

```bash
REQUIRE_ADMIN_MFA=true
```

### Admin Password Policy

Enforce stronger passwords for admins:

```bash
ADMIN_PASSWORD_MIN_LENGTH=16
ADMIN_PASSWORD_EXPIRY_DAYS=30
```

### IP Restrictions

Limit admin access by IP:

```bash
ADMIN_ALLOWED_IPS=10.0.0.0/8,192.168.1.100
```

## Audit Trail

Admin actions are logged:

| Event | Description |
|-------|-------------|
| `admin.login` | Admin login |
| `admin.created` | New admin created |
| `admin.role_changed` | Role modified |
| `client.created` | Client created by admin |
| `settings.changed` | Settings modified |

## Best Practices

{% hint style="success" %}
**Do:**

- Use individual accounts (not shared)
- Enable MFA for all admins
- Regularly review admin list
- Limit super_admin count
{% endhint %}

{% hint style="warning" %}
**Avoid:**

- Shared admin credentials
- Admin accounts without MFA
- Unnecessary admin access
- Using admin accounts for daily work
{% endhint %}

## Removing Admin Access

### Demote to User

```bash
PATCH /api/users/{id}
Content-Type: application/json
Authorization: Bearer {super_admin_token}

{
  "role": "user"
}
```

### Deactivate Admin

```bash
PATCH /api/users/{id}
Content-Type: application/json
Authorization: Bearer {super_admin_token}

{
  "active": false
}
```

## Next Steps

- [Manage Sessions](manage-sessions.md) - Session management
- [Password Reset](password-reset.md) - Reset passwords
- [Enable MFA](../security/enable-mfa.md) - Secure admin accounts
