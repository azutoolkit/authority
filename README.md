<div style="text-align:center"><img src="https://github.com/azutoolkit/authority/blob/main/logo.png"></div>

# Authority

[![Test](https://github.com/azutoolkit/authority/actions/workflows/spec.yml/badge.svg)](https://github.com/azutoolkit/authority/actions/workflows/spec.yml) [![Codacy Badge](https://app.codacy.com/project/badge/Grade/c19b4551de9f43c2b79664af5908f033)](https://www.codacy.com/gh/azutoolkit/authority/dashboard?utm_source=github.com&utm_medium=referral&utm_content=azutoolkit/authority&utm_campaign=Badge_Grade)

https://user-images.githubusercontent.com/1685772/140772737-179dd2e4-0eaa-4915-a942-5e0fe48f0124.mp4

OpenID Connect and OAuth Provider written in Crystal - Security-first, open
source API security for your infrastructure. SDKs to come.

Authority is a OpenID OAuth 2.0 Server and OpenID Connect Provider optimized for
low-latency, high throughput, and low resource consumption. Authority has a built
in identity provider user login.

Implementing and using OAuth2 without understanding the whole specification is
challenging and prone to errors, even when SDKs are being used. The primary goal
of Authority is to make OAuth 2.0 and OpenID Connect 1.0 better accessible.

The specification describes five grants for acquiring an access token:

- Authorization code grant
- Implicit grant
- Resource owner credentials grant
- Client credentials grant
- Refresh token grant

## JSON Web Tokens

At this moment Authority issues JWT OAuth 2.0 Access Tokens as default.

## Features

Grant Types

- [x] Authorization code grant
- [x] Client credentials grant
- [x] Implicit grant
- [x] Resource owner credentials grant
- [x] Refresh token grant
- [x] OpenID Connect
- [x] PKCE
- [ ] Device Code grant
- [ ] Token Introspection
- [ ] Token Revocation

## Configuration

Configuration files can be found in `./src/config`

### Authly.cr

This file contains the configuration for the OAuthly 2 library. Read more about [Authly shards](https://github.com/azutoolkit/authly)

```crystal
# Configure
Authly.configure do |c|
  # Secret Key for JWT Tokens
  c.secret_key = "ExampleSecretKey"

  # Refresh Token Time To Live
  c.refresh_ttl = 1.hour

  # Authorization Code Time To Live
  c.code_ttl = 1.hour

  # Access Token Time To Live
  c.access_ttl = 1.hour

  # Using your own classes
  c.owners = Authority::OwnerService.new
  c.clients = Authority::ClientService.new
end
```

### Clear.cr

This file contains the database configuration. No changes to this files is required.

### Local.env

This file contains the environment variables for Authority.

```bash
CRYSTAL_ENV=development
CRYSTAL_LOG_SOURCES="*"
CRYSTAL_LOG_LEVEL="debug"
CRYSTAL_WORKERS=4
PORT=4000
PORT_REUSE=true
HOST=0.0.0.0
DATABASE_URL=postgres://auth_user:auth_pass@db:5432/authority_db
```

## HTML Templates

You can change the look of Authority `signin` and `authorize` html pages.

Just edit the `./public/templates/signin.html` and `./public/templates/authorize.html`

## Installation

### Docker Compose

Spin up your server

```bash
docker-compose up server
```

## Contributing

1. Fork it (<https://github.com/azutoolkit/authority/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Elias Perez](https://github.com/eliasjpr) - creator and maintainer
