# Error Codes

Reference for Authority API error responses.

## Error Response Format

All errors follow this format:

```json
{
  "error": "error_code",
  "error_description": "Human-readable description",
  "error_uri": "https://docs.example.com/errors/error_code"
}
```

## OAuth 2.0 Errors

### Authorization Endpoint Errors

| Error | Description |
|-------|-------------|
| `invalid_request` | Missing or invalid parameter |
| `unauthorized_client` | Client not authorized for this grant type |
| `access_denied` | User denied authorization |
| `unsupported_response_type` | Response type not supported |
| `invalid_scope` | Invalid or unknown scope |
| `server_error` | Server encountered an error |
| `temporarily_unavailable` | Server is temporarily unavailable |

**Example:**

```
https://app.example.com/callback?error=access_denied&error_description=User%20denied%20access
```

### Token Endpoint Errors

| Error | HTTP Status | Description |
|-------|-------------|-------------|
| `invalid_request` | 400 | Missing required parameter |
| `invalid_client` | 401 | Client authentication failed |
| `invalid_grant` | 400 | Invalid authorization code or refresh token |
| `unauthorized_client` | 400 | Client not authorized for grant type |
| `unsupported_grant_type` | 400 | Grant type not supported |
| `invalid_scope` | 400 | Invalid scope requested |

**Example:**

```json
HTTP/1.1 400 Bad Request
Content-Type: application/json

{
  "error": "invalid_grant",
  "error_description": "The authorization code has expired"
}
```

### Token Introspection Errors

| Error | HTTP Status | Description |
|-------|-------------|-------------|
| `invalid_request` | 400 | Missing token parameter |
| `invalid_client` | 401 | Client authentication failed |

### Device Flow Errors

| Error | HTTP Status | Description |
|-------|-------------|-------------|
| `authorization_pending` | 400 | User hasn't completed authorization |
| `slow_down` | 400 | Polling too frequently |
| `access_denied` | 401 | User denied authorization |
| `expired_token` | 400 | Device code expired |

**Example:**

```json
HTTP/1.1 400 Bad Request
Content-Type: application/json

{
  "error": "authorization_pending",
  "error_description": "The user has not yet completed authorization"
}
```

## OpenID Connect Errors

### UserInfo Errors

| Error | HTTP Status | Description |
|-------|-------------|-------------|
| `invalid_token` | 401 | Token is invalid or expired |
| `insufficient_scope` | 403 | Token lacks required scope |

**Example:**

```json
HTTP/1.1 401 Unauthorized
WWW-Authenticate: Bearer error="invalid_token", error_description="The access token expired"
Content-Type: application/json

{
  "error": "invalid_token",
  "error_description": "The access token expired"
}
```

## HTTP Status Codes

| Status | Meaning |
|--------|---------|
| `200` | Success |
| `201` | Created |
| `302` | Redirect |
| `400` | Bad Request - Invalid parameters |
| `401` | Unauthorized - Authentication required |
| `403` | Forbidden - Insufficient permissions |
| `404` | Not Found - Resource doesn't exist |
| `429` | Too Many Requests - Rate limited |
| `500` | Server Error - Internal error |
| `503` | Service Unavailable - Temporarily down |

## API Errors

### Authentication Errors

| Error | HTTP Status | Description |
|-------|-------------|-------------|
| `authentication_required` | 401 | No valid authentication provided |
| `invalid_credentials` | 401 | Username or password incorrect |
| `account_locked` | 403 | Account is locked |
| `mfa_required` | 403 | MFA verification required |

### Validation Errors

| Error | HTTP Status | Description |
|-------|-------------|-------------|
| `validation_error` | 400 | Request validation failed |
| `missing_parameter` | 400 | Required parameter missing |
| `invalid_parameter` | 400 | Parameter format invalid |

**Example with Details:**

```json
{
  "error": "validation_error",
  "error_description": "Request validation failed",
  "details": [
    {
      "field": "email",
      "message": "Email format is invalid"
    },
    {
      "field": "password",
      "message": "Password must be at least 12 characters"
    }
  ]
}
```

### Resource Errors

| Error | HTTP Status | Description |
|-------|-------------|-------------|
| `not_found` | 404 | Resource not found |
| `already_exists` | 409 | Resource already exists |
| `gone` | 410 | Resource no longer available |

### Rate Limiting Errors

| Error | HTTP Status | Description |
|-------|-------------|-------------|
| `rate_limit_exceeded` | 429 | Too many requests |

**Example:**

```json
HTTP/1.1 429 Too Many Requests
Retry-After: 60
Content-Type: application/json

{
  "error": "rate_limit_exceeded",
  "error_description": "Rate limit exceeded. Retry after 60 seconds.",
  "retry_after": 60
}
```

## Troubleshooting

### Common Issues

| Error | Cause | Solution |
|-------|-------|----------|
| `invalid_client` | Wrong client credentials | Verify client_id and client_secret |
| `invalid_grant` | Expired or used code | Request new authorization code |
| `invalid_redirect_uri` | Mismatched redirect URI | Use exact registered URI |
| `invalid_scope` | Unknown scope | Use only registered scopes |
| `invalid_token` | Expired token | Refresh or re-authenticate |

### Debug Tips

1. Check the `error_description` for details
2. Verify all required parameters are included
3. Ensure client credentials are correct
4. Check token expiration
5. Review server logs for more context

## Next Steps

- [Rate Limits](rate-limits.md) - Rate limiting details
- [API Endpoints](endpoints.md) - Endpoint reference
- [OAuth 2.0 Flows](../oauth2/README.md) - Grant specifications
