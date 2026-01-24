
# Customizing Authentication

You can modify the default behavior of the Authority authentication system by extending the authentication logic.

## Custom OAuth Providers

To add a custom OAuth provider, modify the `OAuth::Client` configuration in the `src/auth.cr` file:

```crystal
OAuth::Client.new do |config|
  config.client_id = ENV["CUSTOM_OAUTH_CLIENT_ID"]
  config.client_secret = ENV["CUSTOM_OAUTH_CLIENT_SECRET"]
end
```

This allows you to connect to other OAuth providers or implement custom authentication logic.
