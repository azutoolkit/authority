# Performance at Scale

OAuth 1.0 requires that the protected resources endpoints have access to the client credentials in order to validate the request. This breaks the typical architecture of most large providers in which a centralized authorization server is used for issuing credentials, and a separate server is used for handling API calls. Because OAuth 1.0 requires the use of the client credentials to verify the signatures, it makes this separation very hard.

OAuth 2.0 addresses this by using the client credentials only when the application obtains authorization from the user. After the credentials are used in the authorization step, only the resulting access token is used when making API calls. This means the API servers do not need to know about the client credentials since they can validate access tokens themselves.
