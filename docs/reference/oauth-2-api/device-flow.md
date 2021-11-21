---
description: >-
  The OAuth 2.0 “Device Flow” extension enables OAuth on devices that have an
  Internet connection but don’t have a browser or an easy way to enter text.
---

# Device Flow

This flow is seen on devices such as smart TVs, media consoles, picture frames, printers, or hardware video encoders. In this flow, the device instructs the user to open a URL on a secondary device such as a smartphone or computer in order to complete the authorization. There is no communication channel required between the user’s two devices.

### Authorization Request

First, the client makes a request to the authorization server to request the device code.

```
POST /device/code HTTP/1.1
Host: authorization-server.com
Content-type: application/x-www-form-urlencoded
 
client_id=a17c21ed
```

{% hint style="info" %}
**Note** that some authorization servers will allow the device to specify a scope in this request, which will be shown to the user later on the authorization interface.
{% endhint %}

The authorization server responds with a JSON payload containing the device code, the code the user will enter, the URL the user should visit, and a polling interval.

```json
HTTP/1.1 200 OK
Content-Type: application/json
Cache-Control: no-store
{
    "device_code": "NGU5OWFiNjQ5YmQwNGY3YTdmZTEyNzQ3YzQ1YSA",
    "user_code": "BDWP-HQPK",
    "verification_uri": "https://authorization-server.com/device",
    "interval": 5,
    "expires_in": 1800
}
```

The `verification_uri` is the URL that the user should navigate to on another device.

The `user_code` is the code that the user should enter once they’ve authenticated with the authorization server.

### Token Request

While the device is waiting for the user to complete the authorization flow on their own computer or phone, the device meanwhile begins polling the token endpoint to request an access token.

The device makes a POST request with the `device_code` at the rate specified by `interval`. The device should continue requesting an access token until a response other than `authorization_pending` is returned, either the user grants or denies the request or the device code expires.

```
POST /device/token HTTP/1.1
Host: authorization-server.com
Content-type: application/x-www-form-urlencoded
 
grant_type=urn:ietf:params:oauth:grant-type:device_code&amp;
client_id=a17c21ed&amp;
device_code=NGU5OWFiNjQ5YmQwNGY3YTdmZTEyNzQ3YzQ1YSA
```

The authorization server will reply with either an error or an access token. The Device Flow spec defines two additional error codes beyond what is defined in OAuth 2.0 core, `authorization_pending` and `slow_down`.

#### Errors

If the device is polling too frequently, the authorization server will return the `slow_down` error.

```json
HTTP/1.1 400 Bad Request
Content-Type: application/json
Cache-Control: no-store
 
{
  "error": "slow_down"
}
```

If the user has not either allowed or denied the request yet, the authorization server will return the `authorization_pending` error.

```json
HTTP/1.1 400 Bad Request
Content-Type: application/json
Cache-Control: no-store
 
{
  "error": "authorization_pending"
}
```

If the user denies the request, the authorization server will return the `access_denied` error.

```json
HTTP/1.1 400 Bad Request
Content-Type: application/json
Cache-Control: no-store
 
{
  "error": "access_denied"
}
```

If the device code has expired, the authorization server will return the `expired_token` error. The device can immediately make a request for a new device code.

```json
HTTP/1.1 400 Bad Request
Content-Type: application/json
Cache-Control: no-store
 
{
  "error": "expired_token"
}
```

### Access Token

Finally, if the user allows the request, then the authorization server issues an access token like normal and returns the standard access token response.

```json
HTTP/1.1 200 OK
Content-Type: application/json
Cache-Control: no-store
 
{
  "access_token": "AYjcyMzY3ZDhiNmJkNTY",
  "refresh_token": "RjY2NjM5NzA2OWJjuE7c",
  "token_type": "bearer",
  "expires": 3600
}
```
