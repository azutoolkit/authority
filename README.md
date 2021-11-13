# Authority

[![Test](https://github.com/azutoolkit/authority/actions/workflows/spec.yml/badge.svg)](https://github.com/azutoolkit/authority/actions/workflows/spec.yml) [![Codacy Badge](https://app.codacy.com/project/badge/Grade/c19b4551de9f43c2b79664af5908f033)](https://www.codacy.com/gh/azutoolkit/authority/dashboard?utm_source=github.com&utm_medium=referral&utm_content=azutoolkit/authority&utm_campaign=Badge_Grade)

![logo](https://user-images.githubusercontent.com/1685772/141647649-241cff93-a5dc-4e6a-9695-ff4b9e6a51d4.png)

<https://user-images.githubusercontent.com/1685772/140772737-179dd2e4-0eaa-4915-a942-5e0fe48f0124.mp4>

A OAuth2 Server, sometimes also referred to as an OAuth 2.0 Server, OAuth Server, Authorization Server, is a software system that implements network protocol flows that allow a client software application to act on behalf of a user.

Authority is a OpenID OAuth 2.0 Server and OpenID Connect Provider optimized for low-latency, high throughput, and low resource consumption. Authority has a built in identity provider user login.

OpenID Connect and OAuth Provider written in Crystal - Security-first, open source API security for your infrastructure. SDKs to come.

## Architecture

Authority follows architecture principles that work best on container orchestration
systems such as Kubernetes, CloudFoundry, OpenShift, and similar projects.
While it is possible to run the Authority stack on a RaspberryPI, the integration
with the Docker and Container ecosystem is best documented and supported.

Authority's architecture is designed along several guiding principles:

- Minimal dependencies (no system dependencies; might need a database backend)
- Runs everywhere (Linux, macOS, FreeBSD, Windows; AMD64, i386, ARMv5, ...)
- Scales without effort (no memcached, etcd, required, ...)
- Minimize room for human and network errors

## About OAuth 2.0

Implementing and using OAuth2 without understanding the whole specification is
challenging and prone to errors, even when SDKs are being used. The primary goal
of Authority is to make OAuth 2.0 and OpenID Connect 1.0 better accessible.

The Authority implements five grants for acquiring an access token:

- Authorization code grant
- Implicit grant
- Resource owner credentials grant
- Client credentials grant
- Refresh token grant

## Why Authority is Different​

Authority differentiates itself in the following key areas:

- Everything is developed and licensed under Open Source Principles, allowing
  you to participate, collaborate, and understand the inner workings of Authority.
- You can bring your own UI, in the programming language of your choosing, with
  the user experience that you like.
- From designing Identity Schemas, to webhooks, to advanced configuration options -
  Authority is fully customizable.
- Authority spans the whole authentication and authorization real with well-designed APIs:
  - Identity Management
  - Session management
  - Flows for login
  - Registration
  - Account recovery & verification
  - Mfa, and many more.

## Roadmap/Features

Grant Types

- [x] Authorization code grant
- [x] Client credentials grant
- [x] Implicit grant
- [x] Resource owner credentials grant
- [x] Refresh token grant
- [x] OpenID Connect
- [x] PKCE
- [x] JSON Web Tokens
- [ ] Device Code grant
- [ ] Token Introspection
- [ ] Token Revocation
- [ ] Opaque Token
- [ ] Client SDKs
- [ ] Session Management
- [ ] Account recovery & verification
- [ ] MFA
- [ ] Permission and Role Management
- [ ] Social Signin

## Configuration

All server Configuration are defined using environment variables

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
  ?initial_pool_size=10&checkout_timeout=3
SECRET_KEY=secret_key
REFRESH_TTL=60
CODE_TTL=5
ACCESS_TOKEN_TTL=60
```

## User Interface Custo

The Managed UI implements screens such as login, registration, account recovery,
account setting, and account verification. This allows for fast adoption of Authority.

Contrary to other vendors, Authority allows you to implement your own UI
by offering simple html templates. You can change the look of Authority `signin`
and `authorize` html pages.

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
