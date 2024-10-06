---
description: >-
  A OAuth2 Server, sometimes also referred to as an OAuth 2.0 Server, OAuth
  Server, Authorization Server, is a software system that implements network
  protocol flows that allow a client software applica
---

# Introduction

{% embed url="https://user-images.githubusercontent.com/1685772/141647649-241cff93-a5dc-4e6a-9695-ff4b9e6a51d4.png" %}

## About Authority Server

Authority is an OAuth 2 Server, sometimes also referred to as an OAuth 2.0 Server, OAuth Server, Authorization Server, is a software system that implements network protocol flows that allow a client software application to act on behalf of a user.

Authority is an OpenID OAuth 2.0 Server and OpenID Connect Provider written in Crystal optimized for low-latency, high throughput, and low resource consumption. Authority has a built in identity provider user login.

Authority is an open source API security for your infrastructure.

### Architecture

Authority follows architecture principles that work best on container orchestration systems such as Kubernetes, CloudFoundry, OpenShift, and similar projects. While it is possible to run the Authority stack on a RaspberryPI, the integration with the Docker and Container ecosystem is best documented and supported.

Authority's architecture is designed along several guiding principles:

* Minimal dependencies (no system dependencies; might need a database backend)
* Runs everywhere (Linux, macOS, FreeBSD, Windows; AMD64, i386, ARMv5, ...)
* Scales without effort (no memcached, etcd, required, ...)
* Minimize room for human and network errors

### OAuth 2 Implementations

Implementing and using OAuth2 without understanding the whole specification is challenging and prone to errors, even when SDKs are being used. The primary goal of Authority is to make OAuth 2.0 and OpenID Connect 1.0 better accessible.

The Authority implements five grants for acquiring an access token:

* Authorization code Grant
* Implicit Grant
* Resource owner credentials grant
* Client credentials grant
* Refresh token Grant
* Device Token Grant

#### Explore the implementations

{% content-ref url="../reference/oauth-2-api/" %}
[oauth-2-api](../reference/oauth-2-api/)
{% endcontent-ref %}

The following RFCs are implemented:

* [RFC6749 "OAuth 2.0"](https://tools.ietf.org/html/rfc6749)
* [RFC6750 " The OAuth 2.0 Authorization Framework: Bearer Token Usage"](https://tools.ietf.org/html/rfc6750)
* [RFC7519 "JSON Web Token (JWT)"](https://tools.ietf.org/html/rfc7519)
* [RFC7636 "Proof Key for Code Exchange by OAuth Public Clients"](https://tools.ietf.org/html/rfc7636)

### Why Authority is Different​

Authority differentiates itself in the following key areas:

* Everything is developed and licensed under Open Source Principles, allowing you to participate, collaborate, and understand the inner workings of Authority.
* You can bring your own UI, in the programming language of your choosing, with the user experience that you like.
* From designing Identity Schemas, to webhooks, to advanced configuration options - Authority is fully customizable.
* Authority spans the whole authentication and authorization real with well-designed APIs:
  * Identity Management
  * Session management
  * Flows for login
  * Registration
  * Account recovery & verification
  * Mfa, and many more.
