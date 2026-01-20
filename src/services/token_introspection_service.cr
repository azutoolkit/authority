# Token Introspection Service (RFC 7662)
# Supports both JWT and opaque token introspection
module Authority
  class TokenIntrospectionService
    @credentials : Tuple(String, String)

    def self.call(auth_header : String, introspect_request : IntrospectRequest)
      new(auth_header, introspect_request).call
    end

    def initialize(@auth_header : String, @introspect_request : IntrospectRequest)
      @credentials = credentials
    end

    def call : TokenInfoResponse
      return TokenInfoResponse.new(client_id, "", "", false) unless authorized?

      token_string = @introspect_request.token

      # Check if it's an opaque token (no dots = not JWT)
      if OpaqueToken.opaque?(token_string)
        introspect_opaque_token(token_string)
      else
        introspect_jwt_token(token_string)
      end
    rescue ex
      TokenInfoResponse.new client_id, "", "", false
    end

    # Introspect opaque token from database
    private def introspect_opaque_token(token_string : String) : TokenInfoResponse
      token = OpaqueToken.find_by(token: token_string)
      return TokenInfoResponse.new(client_id, "", "", false) unless token

      TokenInfoResponse.new(
        client_id,
        token.expires_at.to_unix.to_s,
        token.scope,
        token.active?
      )
    end

    # Introspect JWT token
    private def introspect_jwt_token(token_string : String) : TokenInfoResponse
      exp, scope = parse_jwt_token
      TokenInfoResponse.new client_id, exp, scope, jwt_active?
    rescue ex
      TokenInfoResponse.new client_id, "", "", false
    end

    private def parse_jwt_token
      payload, _ = Authly.jwt_decode @introspect_request.token
      {payload["exp"].to_s, payload["scope"].to_s}
    end

    private def client_id
      credentials.first
    end

    private def jwt_active?
      @introspect_request.valid? && !jwt_expired? && !jwt_revoked?
    end

    private def jwt_expired? : Bool
      payload, _ = Authly.jwt_decode @introspect_request.token
      exp = payload["exp"].as_i64
      Time.utc.to_unix > exp
    rescue
      true
    end

    private def jwt_revoked? : Bool
      payload, _ = Authly.jwt_decode @introspect_request.token
      jti = extract_jti(payload.as_h)
      RevokedToken.revoked?(jti)
    rescue
      false
    end

    private def extract_jti(payload : Hash(String, JSON::Any)) : String
      if payload.has_key?("jti")
        payload["jti"].as_s
      else
        sub = payload["sub"]?.try(&.to_s) || ""
        iat = payload["iat"]?.try(&.to_s) || ""
        "#{sub}:#{iat}"
      end
    end

    private def authorized? : Bool
      Authly.clients.authorized?(*credentials)
    end

    private def credentials : Tuple(String, String)
      value = @auth_header
      creds = value.split(" ").last
      creds = Base64.decode_string(creds).split(":")
      client_id, client_secret = creds
      {client_id, client_secret}
    end
  end
end
