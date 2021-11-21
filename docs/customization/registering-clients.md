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
