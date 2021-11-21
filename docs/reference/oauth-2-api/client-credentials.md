---
description: >-
  The simplest of all of the OAuth 2.0 grants, this grant is suitable for
  machine-to-machine authentication where a specific user’s permission to access
  data is not required.
---

# Client credentials

The Client Credentials grant is used when applications request an access token to access their own resources, not on behalf of a user.

#### Example <a href="example" id="example"></a>

The following is an example authorization code grant the service would receive.

```
POST /token HTTP/1.1
Host: authorization-server.com
 
grant_type=client_credentials
&client_id=xxxxxxxxxx
&client_secret=xxxxxxxxxx
```

****

**The Flow**

The client sends a POST request with following body parameters to the authorization server:

* `grant_type` with the value `client_credentials`
* `client_id` with the the client’s ID
* `client_secret` with the client’s secret
* `scope` with a space-delimited list of requested scope permissions.

The authorization server will respond with a JSON object containing the following properties:

* `token_type` with the value `Bearer`
* `expires_in` with an integer representing the TTL of the access token
* `access_token` the access token itself
