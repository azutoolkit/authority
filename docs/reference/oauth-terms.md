# OAuth Terms

As a refresher here is a quick glossary of OAuth terms (taken from the core spec):

* **Resource owner (a.k.a. the User)** - An entity capable of granting access to a protected resource. When the resource owner is a person, it is referred to as an end-user.
* **Resource server (a.k.a. the API server)** - The server hosting the protected resources, capable of accepting and responding to protected resource requests using access tokens.
* **Client** - An application making protected resource requests on behalf of the resource owner and with its authorization. The term client does not imply any particular implementation characteristics (e.g. whether the application executes on a server, a desktop, or other devices).
* **Authorization server** - The server issues access tokens to the client after successfully authenticating the resource owner and obtaining authorization.

### Access Token Owner <a href="access-token-owner" id="access-token-owner"></a>

An access token represents permission granted to a client to access some protected resources.

If you authorize a machine to access resources and don’t require user permission to access said resources, you should implement the client credentials grant.

### Clients <a href="client-type" id="client-type"></a>

Whether or not the client is capable of keeping a secret will depend on which grant the client should use.

If the client is a web application with a server-side component, you should implement the authorization code grant.

If the client is a web application that has runs entirely on the front end (e.g., a single page web application), you should implement the password grant for first -arty clients and the implicit grant for a third party clients.

If the client is a native application such as a mobile app, you should implement the password grant.

#### First-Party and Third-Party Clients <a href="first-party-or-third-party-client" id="first-party-or-third-party-client"></a>

A first-party client is a client that you trust enough to handle the end user’s authorization credentials. For example, Spotify’s iPhone app is owned and developed by Spotify; therefore, they implicitly trust it.

A third-party client is a client that you don’t trust.
