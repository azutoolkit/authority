# Access Token Response

### Successful Response

If the request for an access token is valid, the authorization server needs to generate an access token (and optional refresh token) and return these to the client, typically along with some additional properties about the authorization.

For example, a successful token response may look like the following:

```json
HTTP/1.1 200 OK
Content-Type: application/json
Cache-Control: no-store
Pragma: no-cache
 
{
  "access_token":"MTQ0NjJkZmQ5OTM2NDE1ZTZjNGZmZjI3",
  "token_type":"bearer",
  "expires_in":3600,
  "refresh_token":"IwOGYzYTlmM2YxOTQ5MGE3YmNmMDFkNTVk",
  "scope":"create"
}
```

#### Access Tokens <a href="token" id="token"></a>

The format for OAuth 2.0 Bearer tokens is actually described in a separate spec, [RFC 6750](https://tools.ietf.org/html/rfc6750). There is no defined structure for the token required by the spec, so you can generate a string and implement tokens however you want. The valid characters in a bearer token are alphanumeric, and the following punctuation characters:

| `-._~+/` |
| -------- |
