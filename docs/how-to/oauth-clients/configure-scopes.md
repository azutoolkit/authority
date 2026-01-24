# Configure Scopes

Create and manage OAuth scopes for access control.

## Overview

Scopes define what access a client can request:

- **Standard scopes** - OpenID Connect scopes (openid, profile, email)
- **Custom scopes** - Application-specific access levels (read, write, admin)

## Default Scopes

Authority includes these standard scopes:

| Scope | Description | Claims |
|-------|-------------|--------|
| `openid` | OpenID Connect | `sub` |
| `profile` | User profile | `name`, `family_name`, `given_name`, `picture` |
| `email` | Email address | `email`, `email_verified` |
| `address` | Postal address | `address` |
| `phone` | Phone number | `phone_number`, `phone_number_verified` |
| `offline_access` | Refresh tokens | - |

## Admin Dashboard

### Create Scope

1. Navigate to **Admin Dashboard** → **Scopes**
2. Click **New Scope**
3. Fill in:

| Field | Description |
|-------|-------------|
| **Name** | Scope identifier (e.g., `read`) |
| **Description** | Human-readable description |
| **Default** | Include in all authorizations |

4. Click **Create**

![Scopes](../../screenshots/admin-scopes.gif)

### Edit Scope

1. Select the scope
2. Modify fields
3. Click **Save**

### Delete Scope

1. Select the scope
2. Click **Delete**
3. Confirm deletion

{% hint style="warning" %}
Deleting a scope may break existing client integrations.
{% endhint %}

## API Management

### Create Scope

```bash
POST /api/scopes
Content-Type: application/json
Authorization: Bearer {admin_token}

{
  "name": "documents:read",
  "description": "Read access to documents",
  "default": false
}
```

### List Scopes

```bash
GET /api/scopes
Authorization: Bearer {admin_token}
```

Response:
```json
{
  "data": [
    {
      "id": "scope-uuid",
      "name": "documents:read",
      "description": "Read access to documents",
      "default": false
    }
  ]
}
```

### Update Scope

```bash
PATCH /api/scopes/{id}
Content-Type: application/json
Authorization: Bearer {admin_token}

{
  "description": "Updated description"
}
```

### Delete Scope

```bash
DELETE /api/scopes/{id}
Authorization: Bearer {admin_token}
```

## Scope Naming Conventions

### Hierarchical Scopes

Use colons to create hierarchies:

```
documents:read
documents:write
documents:delete
users:read
users:write
```

### Resource-Action Pattern

Format: `resource:action`

| Scope | Resource | Action |
|-------|----------|--------|
| `orders:read` | Orders | Read |
| `orders:create` | Orders | Create |
| `products:list` | Products | List |

### API Versioning

Include version if needed:

```
api:v1:read
api:v2:read
```

## Assign Scopes to Clients

When registering or updating a client:

```json
{
  "client_name": "My App",
  "scope": "openid profile email documents:read documents:write"
}
```

## Scope Consent

When users authorize a client, they see requested scopes:

```
My App is requesting access to:

✓ Your profile information
✓ Your email address
✓ Read your documents
✓ Modify your documents

[Allow] [Deny]
```

## Validating Scopes

### At Token Issuance

Authority validates that:

1. Requested scopes exist
2. Client is allowed to request them
3. User consents to them

### In Your API

Check scopes in access tokens:

```javascript
const token = jwt.verify(accessToken, publicKey);
const scopes = token.scope.split(' ');

if (!scopes.includes('documents:read')) {
  throw new ForbiddenError('Insufficient scope');
}
```

## Default Scopes

Set default scopes included in all authorizations:

```bash
DEFAULT_SCOPES=openid profile email
```

Or mark scopes as default in the admin dashboard.

## Scope Dependencies

Define scopes that require other scopes:

```json
{
  "name": "admin",
  "requires": ["read", "write"]
}
```

When `admin` is requested, `read` and `write` are automatically included.

## Best Practices

{% hint style="success" %}
**Do:**

- Use specific scopes (not just `read`/`write`)
- Document what each scope grants
- Use hierarchical naming
- Include scopes in API documentation
{% endhint %}

{% hint style="warning" %}
**Avoid:**

- Overly broad scopes
- Scopes that overlap
- Changing scope meaning after deployment
{% endhint %}

## Next Steps

- [Register Client](register-client.md) - Create OAuth clients
- [Rotate Secrets](rotate-secrets.md) - Secret management
- [Protect Your API](../../tutorials/protect-your-api.md) - Scope enforcement
