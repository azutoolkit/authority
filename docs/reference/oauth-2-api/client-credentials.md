---
description: >-
  The simplest of all of the OAuth 2.0 grants, this grant is suitable for
  machine-to-machine authentication where a specific user’s permission to access
  data is not required.
---

# Client Credentials Flow

The Client Credentials grant type is used by clients to obtain an access token outside of the context of a user. This is typically used by clients to access resources about themselves rather than to access a user's resources.

#### Example <a href="#example" id="example"></a>

The following is an example authorization code grant the service would receive.

```
POST /token HTTP/1.1
Host: authorization-server.com
 
grant_type=client_credentials
&client_id=xxxxxxxxxx
&client_secret=xxxxxxxxxx
```

## Client Credentials

<mark style="color:green;">`POST`</mark> `https://app.com/token`&#x20;

In some cases, applications may need an access token to act on behalf of themselves rather than a user. For example, the service may provide a way for the application to update their own information such as their website URL or icon, or they may wish to get statistics about the users of the app. In this case, applications need a way to get an access token for their own account, outside the context of any specific user. OAuth provides the `client_credentials` grant type for this purpose.

#### Headers

| Name          | Type   | Description                                                                                                                                                                                                                            |
| ------------- | ------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Authorization | String | The client needs to authenticate themselves for this request. Typically the service will allow either additional request parameters `client_id` and `client_secret`, or accept the client ID and secret in the HTTP Basic auth header. |

#### Request Body

| Name                                          | Type   | Description                                                                                                                   |
| --------------------------------------------- | ------ | ----------------------------------------------------------------------------------------------------------------------------- |
| grant\_type<mark style="color:red;">\*</mark> | String | A Parameter must be set to `clienst_credentials`.                                                                             |
| scope                                         | String | The service supports different scopes for the client credentials grant. In practice, not many services actually support this. |

{% tabs %}
{% tab title="201: Created The server replies with an access token in the same format as the other grant types.  Note, the client secret is not included here under the assumption that most of the use cases for password grants will be mobile or desktop apps, where the secret cannot be protected." %}
```javascript
{
  "access_token":"MTQ0NjJkZmQ5OTM2NDE1ZTZjNGZmZjI3",
  "token_type":"bearer",
  "expires_in":3600,
  "refresh_token":"IwOGYzYTlmM2YxOTQ5MGE3YmNmMDFkNTVk",
  "scope":"create"
}
```
{% endtab %}
{% endtabs %}



