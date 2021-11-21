---
description: >-
  Access tokens eventually expire; however some grants respond with a refresh
  token which enables the client to get a new access token without requiring the
  user to be redirected.
---

# Refreshing Access Tokens

#### Example <a href="example" id="example"></a>

The following is an example refresh grant the service would receive.

```json
POST /oauth/token HTTP/1.1
Host: authorization-server.com
 
grant_type=refresh_token
&refresh_token=xxxxxxxxxxx
&client_id=xxxxxxxxxx
&client_secret=xxxxxxxxxx
```

{% swagger method="get" path="" baseUrl="" summary="" %}
{% swagger-description %}

{% endswagger-description %}
{% endswagger %}
