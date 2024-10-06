# Authority

[![Test](https://github.com/azutoolkit/authority/actions/workflows/spec.yml/badge.svg)](https://github.com/azutoolkit/authority/actions/workflows/spec.yml) [![Codacy Badge](https://app.codacy.com/project/badge/Grade/c19b4551de9f43c2b79664af5908f033)](https://www.codacy.com/gh/azutoolkit/authority/dashboard?utm_source=github.com&utm_medium=referral&utm_content=azutoolkit/authority&utm_campaign=Badge_Grade) ![GitHub release (latest by date)](https://img.shields.io/github/v/release/azutoolkit/authority?label=shard) [![documentation](https://img.shields.io/badge/documentation-authority-brightgreen)](https://azutopia.gitbook.io/authority)

![logo](https://user-images.githubusercontent.com/1685772/141647649-241cff93-a5dc-4e6a-9695-ff4b9e6a51d4.png)

A OAuth2 Server, sometimes also referred to as an OAuth 2.0 Server, OAuth Server, Authorization Server, is a software system that implements network protocol flows that allow a client software application to act on behalf of a user.

Authority is a OpenID OAuth 2.0 Server and OpenID Connect Provider written in Crystal optimized for low-latency, high throughput, and low resource consumption. Authority has a built in identity provider user login.

Authority is an open source API security for your infrastructure.

## About OAuth 2.0

Implementing and using OAuth2 without understanding the whole specification is
challenging and prone to errors, even when SDKs are being used. The primary goal
of Authority is to make OAuth 2.0 and OpenID Connect 1.0 better accessible.

The Authority implements five grants for acquiring an access token:

- Authorization code Grant
- Implicit Grant
- Resource owner credentials Grant
- Client credentials Grant
- Refresh token Grant
- Device Token Grant

The following RFCs are implemented:

- [RFC6749 "OAuth 2.0"](https://tools.ietf.org/html/rfc6749)
- [RFC6750 " The OAuth 2.0 Authorization Framework: Bearer Token Usage"](https://tools.ietf.org/html/rfc6750)
- [RFC7519 "JSON Web Token (JWT)"](https://tools.ietf.org/html/rfc7519)
- [RFC7636 "Proof Key for Code Exchange by OAuth Public Clients"](https://tools.ietf.org/html/rfc7636)

Please refer to the project documentation to get started

[![documentation](https://img.shields.io/badge/documentation-authority-brightgreen?style=for-the-badge)](https://azutopia.gitbook.io/authority)

## Contributing

1. Fork it (<https://github.com/azutoolkit/authority/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Elias Perez](https://github.com/eliasjpr) - creator and maintainer
