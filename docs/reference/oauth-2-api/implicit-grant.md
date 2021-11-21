---
description: >-
  The implicit grant is similar to the authorization code grant with two
  distinct differences.
---

# Implicit grant

It is intended to be used for user-agent-based clients (e.g. single page web apps) that can’t keep a client secret because all of the application code and storage are easily accessible.

Secondly, instead of the authorization server returning an authorization code that is exchanged for an access token, the authorization server returns an access token.

#### The Flow <a href="the-flow" id="the-flow"></a>

The client will redirect the user to the authorization server with the following parameters in the query string:

* `response_type` with the value `token`
* `client_id` with the client identifier
* `redirect_uri` with the client redirect URI. This parameter is optional, but if not sent the user will be redirected to a pre-registered redirect URI.
* `scope` a space delimited list of scopes
* `state` with a [CSRF](https://en.wikipedia.org/wiki/Cross-site\_request\_forgery) token. This parameter is optional but highly recommended. You should store the value of the CSRF token in the user’s session to be validated when they return.

```bash
GET https://authorization-server.com/authorize?client_id=a17c21ed
&response_type=code
&state=5ca75bd30
&redirect_uri=https%3A%2F%2Fexample-app.com%2Fauth
&scope=photos
```

All of these parameters will be validated by the authorization server.

The user will then be asked to sign in to the authorization server and approve the client.

If the user approves the client they will be redirected back to the authorization server with the following parameters in the query string

```json
{
  "access_token": "AYjcyMzY3ZDhiNmJkNTY",
  "refresh_token": "RjY2NjM5NzA2OWJjuE7c",
  "token_type": "Bearer",
  "expires": 3600
}
```

