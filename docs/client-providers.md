
# Client Providers

## Overview

Client providers are responsible for managing OAuth clients in the Authority authentication system. They represent applications that request access to user resources on behalf of the users.

## Configuring Client Providers

To set up a client provider, you'll need to configure OAuth settings for your application. This is typically done by registering your application with the OAuth provider (e.g., Google, Facebook).

1. Register your app with the OAuth provider to obtain a client ID and secret.
2. Set the `CLIENT_ID` and `CLIENT_SECRET` in your `.env.local` file.

Example:
```bash
CLIENT_ID=your-client-id
CLIENT_SECRET=your-client-secret
```

## Using Client Providers

Once configured, your application can initiate the OAuth flow by redirecting users to the provider's authorization page. Here's an example of how the flow works:

1. User is redirected to the OAuth provider.
2. After authentication, the user is redirected back to your application with an authorization code.
3. Use this code to request an access token.

```crystal
OAuth::Client.new do |client|
  client.client_id = ENV["CLIENT_ID"]
  client.client_secret = ENV["CLIENT_SECRET"]
end
```

Client providers allow your application to securely interact with OAuth providers on behalf of users.
