# Json Web Tokens

#### Self-Encoded Access Tokens

Self-encoded tokens provide a way to avoid storing tokens in a database by encoding all of the necessary information in the token string itself. The main benefit of this is that API servers are able to verify access tokens without doing a database lookup on every API request, making the API much more easily scalable.

The benefit of OAuth 2.0 Bearer Tokens is that applications don’t need to be aware of how you’ve decided to implement access tokens in your service. This means it’s possible to change your implementation later without affecting clients.

A common technique for this is using the [JSON Web Signature](https://tools.ietf.org/html/rfc7515) (JWS) standard to handle encoding, decoding and verification of tokens. The [JSON Web Token](https://tools.ietf.org/html/rfc7519) (JWT) specification defines some terms you can use in the JWS, as well as defines some timestamp terms to determine whether a token is valid. We’ll use a JWT library in this example, since it provides built-in handling of expiration.
