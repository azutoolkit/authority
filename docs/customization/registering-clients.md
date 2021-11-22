# Registering Clients

When a developer comes to your website, they will need a way to create a new application and obtain credentials. Typically you will have them create a developer account, or create an account on behalf of their organization, before they can create an application.

While the OAuth 2.0 spec doesn’t require you to collect any application information in particular before granting credentials, most services collect basic information about an app, such as the app name and an icon, before issuing the `client_id` and `client_secret`. It is, however, important that you require the developer to register one or more redirect URLs for the application for security purposes. This is explained in more detail in [Redirect URLs](https://www.oauth.com/oauth2-servers/redirect-uris/).

Typically services collect information about an application such as:

* Application name
* An icon for the application
* URL to the application’s home page
* A short description of the application
* A link to the application’s privacy policy
* A list of redirect URLs

### The Client ID and Secret

**Client ID**

The client\_id is a public identifier for apps. Even though it’s public, it’s best that it isn’t guessable by third parties, so many implementations use something like a 32-character hex string. It must also be unique across all clients that the authorization server handles. If the client ID is guessable, it makes it slightly easier to craft phishing attacks against arbitrary applications.

**Client Secret**

The client\_secret is a secret known only to the application and the authorization server. It must be sufficiently random to not be guessable, which means you should avoid using common UUID libraries which often take into account the timestamp or MAC address of the server generating it. A great way to generate a secure secret is to use a cryptographically-secure library to generate a 256-bit value and convert it to a hexadecimal representation.
