---
description: >-
  Access tokens eventually expire; however some grants respond with a refresh
  token which enables the client to get a new access token without requiring the
  user to be redirected.
---

# Refreshing Access Tokens

eWhen you initially received the access token, it may have included a refresh token as well as an expiration time like in the example below.

```json
{
  "access_token": "AYjcyMzY3ZDhiNmJkNTY",
  "refresh_token": "RjY2NjM5NzA2OWJjuE7c",
  "token_type": "bearer",
  "expires": 3600
}
```

The presence of the refresh token means that the access token will expire and you’ll be able to get a new one without the user’s interaction.

The “expires” value is the number of seconds that the access token will be valid. It’s up to the service you’re using to decide how long access tokens will be valid, and may depend on the application or the organization’s own policies. You can use this to preemptively refresh your access tokens instead of waiting for a request with an expired token to fail.

If you make an API request and the token has expired already, you’ll get back a response indicating as such. You can check for this specific error message, and then refresh the token and try the request again.

If you’re using a JSON-based API, then it will likely return a JSON error response with the invalid\_token error. In any case, the `WWW-Authenticate` header will also have the invalid\_token error.

```json
HTTP/1.1 401 Unauthorized
WWW-Authenticate: Bearer error="invalid_token"
  error_description="The access token expired"
Content-type: application/json
 
{
  "error": "invalid_token",
  "error_description": "The access token expired"
}
```

When your code recognizes this specific error, it can then make a request to the token endpoint using the refresh token it previously received, and will get back a new access token it can use to retry the original request.

To use the refresh token, make a POST request to the service’s token endpoint with `grant_type=refresh_token`, and include the refresh token as well as the client credentials.

```bash
POST /token HTTP/1.1
Host: authorization-server.com
 
grant_type=refresh_token
&refresh_token=xxxxxxxxxxx
&client_id=xxxxxxxxxx
&client_secret=xxxxxxxxxx
```

## Refresh Access Token

<mark style="color:green;">`POST`</mark> `https::/app.com/token`

The refresh token, make a POST request to the service’s token endpoint with `grant_type=refresh_token`, and include the refresh token as well as the client credentials.

#### Headers

| Name                                            | Type   | Description                                                                                                                                                                                                                            |
| ----------------------------------------------- | ------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Authorization<mark style="color:red;">\*</mark> | String | The client needs to authenticate themselves for this request. Typically the service will allow either additional request parameters `client_id` and `client_secret`, or accept the client ID and secret in the HTTP Basic auth header. |

#### Request Body

| Name                                             | Type   | Description                    |
| ------------------------------------------------ | ------ | ------------------------------ |
| grant\_type<mark style="color:red;">\*</mark>    | String | Must be set to `refresh_token` |
| refresh\_token<mark style="color:red;">\*</mark> | String | The curent refresh token       |

{% tabs %}
{% tab title="201: Created The response will be a new access token, and optionally a new refresh token, just like you received when exchanging the authorization code for an access token." %}
```javascript
{
  "access_token": "BWjcyMzY3ZDhiNmJkNTY",
  "refresh_token": "Srq2NjM5NzA2OWJjuE7c",
  "token_type": "bearer",
  "expires": 3600
}
```
{% endtab %}
{% endtabs %}
