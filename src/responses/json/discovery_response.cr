# OpenID Connect Discovery Response (RFC 8414 / OpenID Connect Discovery 1.0)
# Returns metadata about the OAuth2/OpenID Connect server
module Authority
  struct OpenIDDiscoveryResponse
    include Response

    def initialize(@issuer : String)
    end

    def render
      {
        # Required fields
        issuer:                                @issuer,
        authorization_endpoint:                "#{@issuer}/authorize",
        token_endpoint:                        "#{@issuer}/token",
        userinfo_endpoint:                     "#{@issuer}/oauth2/userinfo",
        jwks_uri:                              "#{@issuer}/.well-known/jwks.json",

        # Recommended fields
        registration_endpoint:                 nil,
        scopes_supported:                      ["openid", "profile", "email", "read", "write"],
        response_types_supported:              ["code", "token"],
        response_modes_supported:              ["query", "fragment"],
        grant_types_supported:                 [
          "authorization_code",
          "client_credentials",
          "password",
          "refresh_token",
          "urn:ietf:params:oauth:grant-type:device_code",
        ],
        subject_types_supported:               ["public"],
        id_token_signing_alg_values_supported: [algorithm_name],
        token_endpoint_auth_methods_supported: ["client_secret_basic", "client_secret_post"],

        # PKCE support (RFC 7636)
        code_challenge_methods_supported: ["S256", "plain"],

        # Token introspection (RFC 7662)
        introspection_endpoint: "#{@issuer}/oauth/introspect",

        # Token revocation (RFC 7009)
        revocation_endpoint:                       "#{@issuer}/oauth/revoke",
        revocation_endpoint_auth_methods_supported: ["client_secret_basic"],

        # Device authorization (RFC 8628)
        device_authorization_endpoint: "#{@issuer}/device/code",

        # Claims
        claims_supported: [
          "sub",
          "iss",
          "aud",
          "exp",
          "iat",
          "email",
          "email_verified",
          "name",
          "given_name",
          "family_name",
        ],

        # Service documentation
        service_documentation: nil,
        ui_locales_supported:  ["en"],
      }.to_json
    end

    private def algorithm_name : String
      case Authly.config.algorithm
      when JWT::Algorithm::HS256 then "HS256"
      when JWT::Algorithm::HS384 then "HS384"
      when JWT::Algorithm::HS512 then "HS512"
      when JWT::Algorithm::RS256 then "RS256"
      when JWT::Algorithm::RS384 then "RS384"
      when JWT::Algorithm::RS512 then "RS512"
      when JWT::Algorithm::ES256 then "ES256"
      when JWT::Algorithm::ES384 then "ES384"
      when JWT::Algorithm::ES512 then "ES512"
      else                            "HS256"
      end
    end
  end
end
