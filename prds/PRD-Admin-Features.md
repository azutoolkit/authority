# Product Requirements Document: Admin Features Enhancement

**Product:** Authority - OAuth 2.0 Server & OpenID Connect Provider
**Version:** 1.4.5
**Date:** January 2026
**Author:** Generated Analysis

---

## Executive Summary

Authority currently provides a solid admin foundation with user management, client management, scope management, audit logging, and system settings. This PRD identifies **critical missing features** that would elevate Authority to enterprise-grade status and improve operational efficiency for administrators.

---

## Current State Analysis

### Implemented Admin Features

| Feature                 | Status      | Notes                                                     |
| ----------------------- | ----------- | --------------------------------------------------------- |
| User CRUD               | ✅ Complete | Create, read, update, delete with role management         |
| User Lock/Unlock        | ✅ Complete | Manual and automatic lockout with configurable thresholds |
| Password Management     | ✅ Complete | Reset, policies, history tracking                         |
| Session Management      | ✅ Complete | View and revoke user sessions                             |
| OAuth Client Management | ✅ Complete | Full CRUD with secret regeneration                        |
| Scope Management        | ✅ Complete | System and custom scopes                                  |
| Audit Logging           | ✅ Complete | Comprehensive with filtering and CSV export               |
| System Settings         | ✅ Complete | Security, email, branding configuration                   |
| Dashboard Analytics     | ✅ Complete | Basic stats, login activity, recent activity              |
| Bulk Operations         | ✅ Complete | Bulk lock/unlock/delete for users                         |
| CSV Export              | ✅ Complete | Users, clients, audit logs                                |

### Identified Gaps

Based on codebase analysis, the following enterprise features are missing:

---

## Feature Requirements

### Priority 1: Critical (Security & Operations)

---

#### 1.1 Admin REST API

**Problem:** Admin operations are only available via HTML dashboard. No programmatic access exists for automation, integrations, or external tooling.

**Requirement:** Expose all admin operations via a RESTful JSON API.

**Endpoints:**

```
# Users API
GET    /api/admin/users              # List users with pagination/filtering
GET    /api/admin/users/:id          # Get user details
POST   /api/admin/users              # Create user
PATCH  /api/admin/users/:id          # Update user
DELETE /api/admin/users/:id          # Delete user
POST   /api/admin/users/:id/lock     # Lock user
POST   /api/admin/users/:id/unlock   # Unlock user
POST   /api/admin/users/:id/reset-password
GET    /api/admin/users/:id/sessions
DELETE /api/admin/users/:id/sessions/:session_id

# Clients API
GET    /api/admin/clients            # List clients
GET    /api/admin/clients/:id        # Get client
POST   /api/admin/clients            # Create client
PATCH  /api/admin/clients/:id        # Update client
DELETE /api/admin/clients/:id        # Delete client
POST   /api/admin/clients/:id/rotate-secret

# Scopes API
GET    /api/admin/scopes
GET    /api/admin/scopes/:id
POST   /api/admin/scopes
PATCH  /api/admin/scopes/:id
DELETE /api/admin/scopes/:id

# Audit API
GET    /api/admin/audit-logs

# Settings API (super_admin only)
GET    /api/admin/settings
PATCH  /api/admin/settings

# Health API
GET    /api/admin/health
```

**Authentication:** Bearer token with `authority:admin` or `authority:super_admin` scope.

**Acceptance Criteria:**

- [ ] All admin operations available via JSON API
- [ ] OpenAPI/Swagger specification generated
- [ ] Rate limiting applied (separate from user endpoints)
- [ ] All operations logged to audit trail
- [ ] Consistent error response format

**Effort Estimate:** Large

---

#### 1.2 Admin MFA Enforcement

**Problem:** No mechanism to require administrators to enable MFA, creating a security gap.

**Requirement:** Add configuration to enforce MFA for admin accounts.

**Configuration:**

```yaml
security:
  admin_mfa_required: true
  admin_mfa_grace_period_hours: 24 # Time for new admins to enable MFA
```

**Behavior:**

1. When `admin_mfa_required: true`, admins without MFA cannot access dashboard
2. Redirect to MFA setup page with warning message
3. Grace period allows newly created admins time to set up MFA
4. Super admins can grant temporary MFA exemptions (audited)

**UI Changes:**

- Admin list shows MFA status prominently
- Warning banner for admins without MFA
- MFA compliance report in dashboard

**Acceptance Criteria:**

- [ ] Configuration option to enforce admin MFA
- [ ] Grace period for new admin accounts
- [ ] MFA status visible in admin user list
- [ ] Audit log entries for MFA enforcement events
- [ ] Dashboard warning for non-compliant admins

**Effort Estimate:** Medium

---

#### 1.3 IP Allowlist Management UI

**Problem:** IP allowlist service exists in code (`AdminAuthHelper` references it) but no UI for management.

**Requirement:** Admin interface to manage IP allowlists for dashboard access.

**Features:**

- Add/remove IP addresses and CIDR ranges
- Named allowlist entries with descriptions
- Enable/disable allowlist enforcement
- Audit logging of allowlist changes
- Temporary bypass tokens (time-limited)

**UI Design:**

```
/dashboard/settings/ip-allowlist

+------------------------------------------+
| IP Allowlist Configuration               |
+------------------------------------------+
| [x] Enable IP Allowlist Enforcement      |
+------------------------------------------+
| Allowed IPs/Ranges                       |
| +--------------------------------------+ |
| | 192.168.1.0/24  | Office Network | X | |
| | 10.0.0.5        | VPN Exit       | X | |
| +--------------------------------------+ |
| [ Add IP/CIDR Range ]                    |
+------------------------------------------+
| Temporary Bypass (expires in 24h)        |
| Token: abc123... [Copy] [Revoke]         |
+------------------------------------------+
```

**Acceptance Criteria:**

- [ ] CRUD operations for IP allowlist entries
- [ ] CIDR range validation
- [ ] Enable/disable toggle
- [ ] Temporary bypass token generation
- [ ] Audit logging of all changes
- [ ] Lock-out prevention (current admin IP always allowed)

**Effort Estimate:** Medium

---

#### 1.4 Security Alerts & Notifications

**Problem:** No mechanism to alert administrators of security events in real-time.

**Requirement:** Notification system for critical security events.

**Events to Monitor:**

| Event                                       | Severity | Default Action    |
| ------------------------------------------- | -------- | ----------------- |
| Multiple failed logins (threshold exceeded) | High     | Email + Dashboard |
| Admin account created                       | High     | Email             |
| Admin login from new IP                     | Medium   | Email             |
| User account locked                         | Medium   | Dashboard         |
| Client secret regenerated                   | Medium   | Dashboard         |
| Bulk operation performed                    | Medium   | Dashboard         |
| Settings changed                            | High     | Email             |
| Unusual login pattern detected              | High     | Email             |

**Notification Channels:**

- Email (SMTP already configured)
- Dashboard notifications (bell icon with badge)
- Webhook (for external integrations)

**Database Schema:**

```sql
CREATE TABLE admin_notifications (
  id UUID PRIMARY KEY,
  admin_id UUID REFERENCES oauth_owners(id),
  event_type VARCHAR(50) NOT NULL,
  severity VARCHAR(20) NOT NULL,
  title VARCHAR(255) NOT NULL,
  message TEXT,
  metadata JSONB,
  read_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE notification_preferences (
  admin_id UUID PRIMARY KEY REFERENCES oauth_owners(id),
  email_enabled BOOLEAN DEFAULT true,
  email_severity_threshold VARCHAR(20) DEFAULT 'medium',
  webhook_url TEXT,
  webhook_enabled BOOLEAN DEFAULT false
);
```

**Acceptance Criteria:**

- [ ] Dashboard notification center (bell icon)
- [ ] Email notifications for high-severity events
- [ ] Per-admin notification preferences
- [ ] Notification history with pagination
- [ ] Mark as read functionality
- [ ] Webhook integration option

**Effort Estimate:** Large

---

### Priority 2: High (Operational Efficiency)

---

#### 2.1 Bulk Import/Provisioning

**Problem:** No way to bulk import users or clients. Large deployments require manual creation.

**Requirement:** CSV/JSON import functionality for users and clients.

**User Import Format (CSV):**

```csv
username,email,role,scope,temp_password,send_welcome_email
john.doe,john@example.com,user,read write,TempPass123!,true
admin.jane,jane@example.com,admin,authority:admin,AdminPass456!,true
```

**Client Import Format (JSON):**

```json
{
  "clients": [
    {
      "name": "Mobile App",
      "redirect_uri": "myapp://callback",
      "grant_types": ["authorization_code"],
      "scopes": ["openid", "profile"],
      "confidential": false
    }
  ]
}
```

**Features:**

- Dry-run mode (validate without importing)
- Error report with line numbers
- Duplicate detection (skip or update)
- Progress indicator for large imports
- Audit log entry for each imported record

**UI:**

```
/dashboard/users/import
/dashboard/clients/import

+------------------------------------------+
| Import Users from CSV                    |
+------------------------------------------+
| [Drag & drop CSV file here]              |
|                                          |
| [x] Send welcome emails                  |
| [x] Skip duplicates (by email)           |
| [ ] Update existing records              |
|                                          |
| [Validate] [Import]                      |
+------------------------------------------+
| Validation Results:                      |
| ✓ 48 valid records                       |
| ✗ 2 errors (see below)                   |
| - Row 12: Invalid email format           |
| - Row 34: Password too weak              |
+------------------------------------------+
```

**Acceptance Criteria:**

- [ ] CSV import for users
- [ ] JSON import for clients
- [ ] Dry-run validation mode
- [ ] Detailed error reporting
- [ ] Duplicate handling options
- [ ] Progress feedback for large imports
- [ ] Audit logging per record

**Effort Estimate:** Large

---

#### 2.2 Consent Management Dashboard

**Problem:** No visibility into user OAuth consents. Users cannot view or revoke application access.

**Requirement:** Admin view of all consents and user self-service consent management.

**Admin Features:**

- View all active consents across users
- Filter by client, user, scope, date
- Bulk revoke consents for a client
- Consent statistics (most authorized apps)

**User Self-Service:**

- View authorized applications on profile page
- Revoke access for specific applications
- See what data each app can access (scopes)
- Last used timestamp

**Database Schema:**

```sql
CREATE TABLE oauth_consents (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES oauth_owners(id),
  client_id UUID NOT NULL REFERENCES oauth_clients(id),
  scopes TEXT[] NOT NULL,
  granted_at TIMESTAMP DEFAULT NOW(),
  last_used_at TIMESTAMP,
  revoked_at TIMESTAMP,
  UNIQUE(user_id, client_id)
);
```

**Admin UI:**

```
/dashboard/consents

+------------------------------------------+
| OAuth Consent Management                 |
+------------------------------------------+
| Filter: [Client ▼] [User search] [Date]  |
+------------------------------------------+
| User          | Client     | Scopes   | Granted    |
| john@ex.com   | Mobile App | profile  | 2024-01-15 |
| jane@ex.com   | Web Portal | openid   | 2024-01-10 |
+------------------------------------------+
| Bulk Actions: [Revoke Selected]          |
+------------------------------------------+
```

**User Profile Section:**

```
/profile/authorized-apps

+------------------------------------------+
| Authorized Applications                  |
+------------------------------------------+
| Mobile App                               |
| Can access: Profile, Email               |
| Authorized: Jan 15, 2024                 |
| Last used: 2 hours ago                   |
| [Revoke Access]                          |
+------------------------------------------+
```

**Acceptance Criteria:**

- [ ] Admin consent listing with filters
- [ ] User profile section for authorized apps
- [ ] Individual consent revocation
- [ ] Bulk revocation for admins
- [ ] Consent audit logging
- [ ] Last used tracking

**Effort Estimate:** Medium

---

#### 2.3 Client Usage Analytics

**Problem:** Limited visibility into OAuth client usage patterns.

**Requirement:** Detailed analytics dashboard for OAuth client activity.

**Metrics:**

- Token requests per client (daily/weekly/monthly)
- Unique users per client
- Most used scopes per client
- Error rates (failed authentications)
- Token introspection volume
- Geographic distribution (based on IP)

**Dashboard Widgets:**

```
/dashboard/clients/:id/analytics

+------------------------------------------+
| Client: Mobile App - Analytics           |
+------------------------------------------+
| Token Requests (Last 30 Days)            |
| [Line chart showing daily volume]        |
+------------------------------------------+
| Active Users: 1,234 | Total Auths: 45.2K |
+------------------------------------------+
| Top Scopes          | Error Breakdown    |
| 1. openid (95%)     | Invalid grant: 2%  |
| 2. profile (87%)    | Expired: 1%        |
| 3. email (65%)      | Revoked: 0.5%      |
+------------------------------------------+
| Peak Hours: 9-11 AM UTC                  |
+------------------------------------------+
```

**Data Collection:**

- Aggregate statistics (not individual tracking)
- Configurable retention period
- Export to CSV/JSON

**Acceptance Criteria:**

- [ ] Per-client analytics dashboard
- [ ] Token request volume charts
- [ ] Active user counts
- [ ] Error rate tracking
- [ ] Scope usage breakdown
- [ ] Configurable date ranges
- [ ] Data export functionality

**Effort Estimate:** Large

---

#### 2.4 Custom Admin Roles

**Problem:** Only two roles exist (admin, user) with super_admin as a scope. No granular permissions.

**Requirement:** Flexible role-based access control for admin functions.

**Predefined Roles:**
| Role | Permissions |
|------|-------------|
| Super Admin | Full access to all features |
| User Admin | Manage users, view audit logs |
| Client Admin | Manage OAuth clients and scopes |
| Auditor | Read-only access to all data and audit logs |
| Support | View users, reset passwords, unlock accounts |

**Custom Roles:**
Allow creating custom roles with specific permissions:

```json
{
  "name": "regional_admin",
  "permissions": [
    "users:read",
    "users:create",
    "users:update",
    "users:lock",
    "users:unlock",
    "clients:read",
    "audit:read"
  ]
}
```

**Permission Matrix:**

```
+-------------------+-------+-------+--------+--------+--------+
| Resource          | Read  | Create| Update | Delete | Special|
+-------------------+-------+-------+--------+--------+--------+
| Users             |   x   |   x   |   x    |   x    | lock   |
| Clients           |   x   |   x   |   x    |   x    | rotate |
| Scopes            |   x   |   x   |   x    |   x    |        |
| Audit Logs        |   x   |       |        |        | export |
| Settings          |   x   |       |   x    |        |        |
| Roles             |   x   |   x   |   x    |   x    |        |
+-------------------+-------+-------+--------+--------+--------+
```

**Database Schema:**

```sql
CREATE TABLE admin_roles (
  id UUID PRIMARY KEY,
  name VARCHAR(50) UNIQUE NOT NULL,
  description TEXT,
  permissions TEXT[] NOT NULL,
  is_system BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP
);

CREATE TABLE admin_role_assignments (
  admin_id UUID REFERENCES oauth_owners(id),
  role_id UUID REFERENCES admin_roles(id),
  assigned_by UUID REFERENCES oauth_owners(id),
  assigned_at TIMESTAMP DEFAULT NOW(),
  PRIMARY KEY (admin_id, role_id)
);
```

**Acceptance Criteria:**

- [ ] Predefined system roles
- [ ] Custom role creation
- [ ] Permission-based UI element visibility
- [ ] Role assignment to admins
- [ ] Audit logging of role changes
- [ ] API permission checking

**Effort Estimate:** Large

---

### Priority 3: Medium (Enhanced Experience)

---

#### 3.1 System Health Dashboard

**Problem:** No visibility into system health, database connections, or service status.

**Requirement:** Real-time health monitoring dashboard.

**Metrics:**

- Database connection pool status
- Redis connection status (if enabled)
- Response time percentiles (p50, p95, p99)
- Request rate (requests/second)
- Error rate
- Memory usage
- Active sessions count
- Token table sizes

**UI Design:**

```
/dashboard/health

+------------------------------------------+
| System Health                     [Live] |
+------------------------------------------+
| Services                                 |
| ● PostgreSQL    Connected (12/20 pool)   |
| ● Redis         Connected (healthy)      |
| ● SMTP          Configured               |
+------------------------------------------+
| Performance (Last Hour)                  |
| Requests: 12,450 | Errors: 23 (0.18%)    |
| p50: 12ms | p95: 45ms | p99: 120ms       |
+------------------------------------------+
| Storage                                  |
| Users: 1,234 | Clients: 56 | Tokens: 8.9K|
| Audit Logs: 125K (45 days retained)      |
+------------------------------------------+
| Memory: 245MB / 512MB                    |
| [Export Health Report]                   |
+------------------------------------------+
```

**Acceptance Criteria:**

- [ ] Real-time service status indicators
- [ ] Database pool monitoring
- [ ] Response time metrics
- [ ] Error rate tracking
- [ ] Storage statistics
- [ ] Health report export
- [ ] Configurable alert thresholds

**Effort Estimate:** Medium

---

#### 3.2 Backup & Restore Configuration

**Problem:** No built-in mechanism to backup/restore system configuration.

**Requirement:** Export and import system configuration (excluding user data).

**Exportable Items:**

- System settings
- OAuth scopes (non-system)
- Admin roles (custom)
- IP allowlist
- Notification preferences

**Export Format:**

```json
{
  "export_version": "1.0",
  "exported_at": "2024-01-20T10:00:00Z",
  "exported_by": "admin@example.com",
  "settings": { ... },
  "scopes": [ ... ],
  "roles": [ ... ],
  "ip_allowlist": [ ... ]
}
```

**Features:**

- Encrypted export option
- Selective export (choose what to include)
- Dry-run import (preview changes)
- Conflict resolution options

**Acceptance Criteria:**

- [ ] Configuration export to JSON
- [ ] Configuration import with validation
- [ ] Encryption option for exports
- [ ] Selective export
- [ ] Dry-run import mode
- [ ] Audit logging of imports

**Effort Estimate:** Medium

---

#### 3.3 Scheduled Reports

**Problem:** No automated reporting for compliance or operational oversight.

**Requirement:** Scheduled email reports for administrators.

**Report Types:**
| Report | Frequency Options | Content |
|--------|-------------------|---------|
| Security Summary | Daily/Weekly | Failed logins, lockouts, MFA changes |
| User Activity | Weekly/Monthly | New users, deleted users, role changes |
| Client Usage | Weekly/Monthly | Token volumes, top clients, errors |
| Audit Summary | Weekly/Monthly | Actions by admin, by type |
| Compliance | Monthly | MFA adoption, password age, inactive users |

**Configuration:**

```
/dashboard/settings/reports

+------------------------------------------+
| Scheduled Reports                        |
+------------------------------------------+
| Security Summary                         |
| [x] Enabled | Frequency: [Daily ▼]       |
| Recipients: admin@ex.com, sec@ex.com     |
| Send time: 8:00 AM UTC                   |
+------------------------------------------+
| [+ Add Report Schedule]                  |
+------------------------------------------+
```

**Acceptance Criteria:**

- [ ] Multiple report types
- [ ] Configurable frequency
- [ ] Multiple recipients per report
- [ ] Report preview/test send
- [ ] Audit log of sent reports
- [ ] Unsubscribe handling

**Effort Estimate:** Large

---

#### 3.4 Admin Activity Log (Enhanced)

**Problem:** Current audit log tracks actions but doesn't provide admin-focused insights.

**Requirement:** Dedicated view for monitoring admin activity patterns.

**Features:**

- Filter by specific admin
- Activity timeline visualization
- Unusual activity detection
- Session correlation (group actions by session)
- Compare activity across admins

**UI:**

```
/dashboard/admin-activity

+------------------------------------------+
| Admin Activity Monitor                   |
+------------------------------------------+
| [Admin: All ▼] [Period: Last 7 days ▼]   |
+------------------------------------------+
| admin@example.com                        |
| ├─ Jan 20, 10:00 - Session started       |
| ├─ Jan 20, 10:05 - Viewed users list     |
| ├─ Jan 20, 10:12 - Updated user #123     |
| └─ Jan 20, 10:30 - Session ended         |
+------------------------------------------+
| Activity Summary                         |
| Most active: admin@ex.com (145 actions)  |
| Busiest day: Monday (avg 230 actions)    |
| Peak hour: 10:00-11:00 AM                |
+------------------------------------------+
```

**Acceptance Criteria:**

- [ ] Per-admin activity filtering
- [ ] Timeline visualization
- [ ] Session grouping
- [ ] Activity statistics
- [ ] Unusual pattern flagging
- [ ] Export functionality

**Effort Estimate:** Medium

---

#### 3.5 Webhooks for Admin Events

**Problem:** No way to integrate admin events with external systems (SIEM, Slack, etc.).

**Requirement:** Webhook subscriptions for admin and security events.

**Subscribable Events:**

- `user.created`, `user.updated`, `user.deleted`
- `user.locked`, `user.unlocked`
- `user.login_failed`, `user.login_success`
- `client.created`, `client.updated`, `client.deleted`
- `client.secret_rotated`
- `settings.updated`
- `admin.login`

**Webhook Configuration:**

```json
{
  "url": "https://hooks.example.com/authority",
  "events": ["user.locked", "user.login_failed"],
  "secret": "webhook_signing_secret",
  "enabled": true,
  "retry_policy": {
    "max_attempts": 3,
    "backoff_seconds": [5, 30, 300]
  }
}
```

**Payload Format:**

```json
{
  "id": "evt_abc123",
  "type": "user.locked",
  "timestamp": "2024-01-20T10:00:00Z",
  "data": {
    "user_id": "uuid",
    "email": "user@example.com",
    "reason": "Too many failed login attempts",
    "locked_by": "system"
  },
  "signature": "sha256=..."
}
```

**Acceptance Criteria:**

- [ ] Webhook endpoint configuration
- [ ] Event subscription selection
- [ ] HMAC signature verification
- [ ] Retry with exponential backoff
- [ ] Delivery status tracking
- [ ] Test webhook functionality
- [ ] Webhook logs

**Effort Estimate:** Large

---

## Implementation Roadmap

### Phase 1: Security Foundation (Q1)

1. Admin MFA Enforcement
2. IP Allowlist Management UI
3. Security Alerts & Notifications (Dashboard only)

### Phase 2: API & Integration (Q1-Q2)

1. Admin REST API
2. Webhooks for Admin Events
3. Security Alerts & Notifications (Email + Webhook)

### Phase 3: Operational Excellence (Q2)

1. Bulk Import/Provisioning
2. Consent Management Dashboard
3. System Health Dashboard

### Phase 4: Advanced Features (Q2-Q3)

1. Custom Admin Roles
2. Client Usage Analytics
3. Scheduled Reports
4. Backup & Restore Configuration

### Phase 5: Polish (Q3)

1. Admin Activity Log (Enhanced)
2. Documentation updates
3. SDK support for Admin API

---

## Success Metrics

| Metric                | Target                                          |
| --------------------- | ----------------------------------------------- |
| Admin API adoption    | 50% of admin operations via API within 6 months |
| MFA compliance        | 100% admin MFA adoption when enforced           |
| Alert response time   | <15 min for critical security alerts            |
| Import success rate   | >95% for bulk imports                           |
| Webhook delivery rate | >99.5% successful delivery                      |

---

## Dependencies

- **Email Service:** Required for notifications and reports
- **Redis:** Recommended for webhook queue and real-time features
- **External:** SMTP server configuration for email features

---

## Risks & Mitigations

| Risk                  | Mitigation                                        |
| --------------------- | ------------------------------------------------- |
| API abuse             | Rate limiting, audit logging, IP-based throttling |
| Webhook failures      | Retry logic, dead letter queue, admin alerts      |
| Permission escalation | Strict RBAC checks, audit all permission changes  |
| Import data quality   | Validation, dry-run mode, rollback capability     |

---

## Appendix

### A. API Response Format

```json
{
  "success": true,
  "data": { ... },
  "meta": {
    "page": 1,
    "per_page": 20,
    "total": 150
  }
}
```

### B. Error Response Format

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid email format",
    "details": [
      { "field": "email", "message": "Must be a valid email address" }
    ]
  }
}
```

### C. Webhook Signature Verification

```python
import hmac
import hashlib

def verify_webhook(payload, signature, secret):
    expected = hmac.new(
        secret.encode(),
        payload.encode(),
        hashlib.sha256
    ).hexdigest()
    return hmac.compare_digest(f"sha256={expected}", signature)
```
