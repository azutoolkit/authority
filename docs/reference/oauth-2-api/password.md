# Password

The Password grant is used when the application exchanges the user’s username and password for an access token.&#x20;

{% hint style="warning" %}
This is exactly the thing OAuth was created to prevent in the first place, so you should **never** allow third-party apps to use this grant.
{% endhint %}

A common use for this grant type is to enable password logins for your service’s own apps. Users won’t be surprised to log in to the service’s website or native application using their username and password, but third-party apps should never be allowed to ask the user for their password.

#### Example <a href="example" id="example"></a>

The following is an example password grant the service would receive.

```
POST /oauth/token HTTP/1.1
Host: authorization-server.com
 
grant_type=password
&username=user@example.com
&password=1234luggage
&client_id=xxxxxxxxxx
&client_secret=xxxxxxxxxx

```

See [Access Token Response](https://www.oauth.com/oauth2-servers/access-tokens/access-token-response/) for details on the parameters to return when generating an access token or responding to errors.
