---
description: >-
  The authorization code grant should be very familiar if you’ve ever signed
  into an application using your Facebook or Google account.
---

# Authorization Flow

### The Flow (Part One) <a href="the-flow-part-one" id="the-flow-part-one"></a>

The client will redirect the user to the authorization server with the following parameters in the query string:

* `response_type` with the value `code`
* `client_id` with the client identifier
* `redirect_uri` with the client redirect URI. This parameter is optional, but if not send the user will be redirected to a pre-registered redirect URI.
* `scope` a space delimited list of scopes
* `state` with a [CSRF](https://en.wikipedia.org/wiki/Cross-site\_request\_forgery) token. This parameter is optional but highly recommended. You should store the value of the CSRF token in the user’s session to be validated when they return.

```bash
GET https://authorization-server.com/authorize?client_id=a17c21ed
&response_type=code
&state=5ca75bd30
&redirect_uri=https%3A%2F%2Fexample-app.com%2Fauth
&scope=photos
```

The parameters will be validated by the authorization server.

{% hint style="info" %}
**Good to know:**&#x20;

The user will then be asked to sign in to the authorization server and approve the client.

If the user approves the client they will be redirected from the authorisation server back to the client (specifically to the redirect URI) with the following parameters in the query string:

* `code` with the authorization code
* `state` with the state parameter sent in the original request. You should compare this value with the value stored in the user’s session to ensure the authorization code obtained is in response to requests made by this client rather than another client application.
{% endhint %}

#### PKCE Extension

The Proof Key for Code Exchange (PKCE, pronounced pixie) extension describes a technique for public clients to mitigate the threat of having the authorization code intercepted. The technique involves the client first creating a secret, and then using that secret again when exchanging the authorization code for an access token. This way if the code is intercepted, it will not be useful since the token request relies on the initial secret.

Once the app has generated the code verifier, it uses that to create the _code challenge_. For devices that can perform a SHA256 hash, the code challenge is a BASE64-URL-encoded string of the SHA256 hash of the code verifier. Clients that do not have the ability to perform a SHA256 hash are permitted to use the plain code verifier string as the challenge.

Now that the client has a _code challenge_ string, it includes that and a parameter that indicates which method was used to generate the challenge (plain or S256) along with the standard parameters of the authorization request. This means a complete authorization request will include the following parameters.

```bash
GET https://authorization-server.com/authorize?client_id=a17c21ed
&response_type=code
&state=5ca75bd30
&redirect_uri=https%3A%2F%2Fexample-app.com%2Fauth
&scope=photos
&code_challenge=XXXXXXXX
&code_challenge_method=S256
```

{% hint style="success" %}
The PKCE extension does not add any new responses, so clients can always use the PKCE extension even if an authorization server does not support it.
{% endhint %}

### The Flow (Part Two) <a href="the-flow-part-two" id="the-flow-part-two"></a>

**Exchange the authorization code for an access token**

To exchange the authorization code for an access token, the app makes a POST request to the service’s token endpoint. The request will have the following parameters.

```bash
POST /oauth/token HTTP/1.1
Host: authorization-server.com
 
code=Yzk5ZDczMzRlNDEwY
&grant_type=code
&redirect_uri=https://example-app.com/cb
&client_id=mRkZGFjM
&client_secret=ZGVmMjMz
&code_verifier=a6b602d858ae0da189dacd297b188ef308dc754bd9cc359ac2e1d8d1
```

{% swagger method="post" path=" " baseUrl="https://my-auth-server.com/token" summary="Creates an Access Token" %}
{% swagger-description %}
The server exchanges the authorization code for an access token by making a POST request to the token endpoint.
{% endswagger-description %}

{% swagger-parameter in="header" name="Authorization" required="true" %}
Contains the word Basic, followed by a space and a base64-encoded(non-encrypted) string with the 

_client id _

and

_ client_

 

_secret_
{% endswagger-parameter %}

{% swagger-parameter in="body" name="grant_type" required="true" %}
The grant type for this flow is 

**authorization_code**
{% endswagger-parameter %}

{% swagger-parameter in="body" name="redirect_uri" required="true" %}
Must be identical to the redirect URI provided in the original link
{% endswagger-parameter %}

{% swagger-parameter in="body" name="code" required="true" %}
The authorization code from the query string
{% endswagger-parameter %}

{% swagger-parameter in="body" name="code_verifier" %}
PCKE Extension - the code verifier for the PKCE request, that the app originally generated before the authorization request.
{% endswagger-parameter %}

{% swagger-response status="201: Created" description="The authorization server will respond with a JSON object containing the following properties:" %}
```javascript
{
  "access_token": "AYjcyMzY3ZDhiNmJkNTY",
  "refresh_token": "RjY2NjM5NzA2OWJjuE7c",
  "token_type": "Bearer",
  "expires": 3600
}
```
{% endswagger-response %}
{% endswagger %}

**OAuth Security**

Up until 2019, the OAuth 2.0 spec only recommended using the [PKCE](https://www.oauth.com/oauth2-servers/pkce/) extension for mobile and JavaScript apps. The latest OAuth Security BCP now recommends using PKCE also for server-side apps, as it provides some additional benefits there as well. It is likely to take some time before common OAuth services adapt to this new recommendation, but if you’re building a server from scratch you should definitely support PKCE for all types of clients.
