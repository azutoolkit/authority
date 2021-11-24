# Open ID Connect

OpenID Connect provides user identity and authentication on top of the OAuth 2.0 framework. You can use OpenID Connect to establish a login session, and use OAuth to access protected resources.

You can request both an ID token and access token in the same flow in order to both authenticate the user as well as obtain authorization to access a protected resource.

OpenID Connect is maintained by the [OpenID Foundation](https://openid.net). The core OpenID Connect spec, as well as many extensions, can be read in full on [https://openid.net/connect/](https://openid.net/connect/).

The [OpenID Connect Debugger](https://oidcdebugger.com) is a fantastic resource to help you build OpenID Connect requests and walk through the flows. Additionally, the [OAuth 2.0 Playground](https://www.oauth.com/playground/) provides a walkthrough of the OpenID Connect flow against a live server.

{% swagger src="../../.gitbook/assets/openid.yaml" path="undefined" method="undefined" %}
[openid.yaml](../../.gitbook/assets/openid.yaml)
{% endswagger %}

{% swagger src="../../.gitbook/assets/openid.yaml" path="/.well-known/jwks.json" method="get" %}
[openid.yaml](../../.gitbook/assets/openid.yaml)
{% endswagger %}

{% swagger src="../../.gitbook/assets/openid.yaml" path="/userinfo" method="get" %}
[openid.yaml](../../.gitbook/assets/openid.yaml)
{% endswagger %}

{% swagger src="../../.gitbook/assets/openid.yaml" path="/userinfo" method="post" %}
[openid.yaml](../../.gitbook/assets/openid.yaml)
{% endswagger %}

{% swagger src="../../.gitbook/assets/openid.yaml" path="/register" method="post" %}
[openid.yaml](../../.gitbook/assets/openid.yaml)
{% endswagger %}

{% swagger src="../../.gitbook/assets/openid.yaml" path="/register/{client_id}" method="get" %}
[openid.yaml](../../.gitbook/assets/openid.yaml)
{% endswagger %}

{% swagger src="../../.gitbook/assets/openid.yaml" path="/register/{client_id}" method="delete" %}
[openid.yaml](../../.gitbook/assets/openid.yaml)
{% endswagger %}

{% swagger src="../../.gitbook/assets/openid.yaml" path="/register/{client_id}" method="patch" %}
[openid.yaml](../../.gitbook/assets/openid.yaml)
{% endswagger %}

{% swagger src="../../.gitbook/assets/openid.yaml" path="/register/{client_id}/renew_secret" method="post" %}
[openid.yaml](../../.gitbook/assets/openid.yaml)
{% endswagger %}

