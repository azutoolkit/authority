
# Authentication

Authority provides a simple yet flexible authentication system using OAuth. 

## Setting up OAuth

1. Register your application with the desired OAuth provider.
2. Obtain the client ID and client secret.
3. Set these in the environment variables `OAUTH_CLIENT_ID` and `OAUTH_CLIENT_SECRET`.

## OAuth Flow

- Users will be redirected to the OAuth provider for authentication.
- Once authenticated, the provider will return an authorization code.
- This code can be exchanged for an access token, which can be used for further API requests.

