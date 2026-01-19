# Token Revocation Service (RFC 7009)
# Handles token revocation by storing the token's JTI in the revoked_tokens table
module Authority
  class TokenRevocationService
    @credentials : Tuple(String, String)

    def self.call(auth_header : String, revoke_request : RevokeRequest)
      new(auth_header, revoke_request).call
    end

    def initialize(@auth_header : String, @revoke_request : RevokeRequest)
      @credentials = credentials
    end

    def call : RevokeResponse
      # Per RFC 7009, we return 200 OK even if the token is invalid
      # This prevents token scanning attacks
      return RevokeResponse.new unless @revoke_request.valid?
      return RevokeResponse.new unless authorized?

      revoke_token!
      RevokeResponse.new
    rescue ex
      # Per RFC 7009, we don't reveal errors to prevent information leakage
      RevokeResponse.new
    end

    private def revoke_token!
      payload_any, _ = Authly.jwt_decode @revoke_request.token
      payload = payload_any.as_h
      jti = extract_jti(payload)
      exp = Time.unix(payload["exp"].as_i64)
      token_type = determine_token_type(payload)

      RevokedToken.revoke!(jti, client_id, token_type, exp)
    rescue ex
      # Token is invalid or already expired, silently ignore
    end

    private def extract_jti(payload : Hash(String, JSON::Any)) : String
      # JWT ID claim, or generate one from the token's sub and iat
      if payload.has_key?("jti")
        payload["jti"].as_s
      else
        # Generate a deterministic ID from sub + iat
        sub = payload["sub"]?.try(&.to_s) || ""
        iat = payload["iat"]?.try(&.to_s) || ""
        "#{sub}:#{iat}"
      end
    end

    private def determine_token_type(payload : Hash(String, JSON::Any)) : String
      # Refresh tokens typically have longer expiry and may have different claims
      # Check token_type_hint first, then try to determine from payload
      hint = @revoke_request.token_type_hint
      return hint if hint && (hint == "access_token" || hint == "refresh_token")

      # If the token has an "name" claim, it's likely a refresh token
      # (based on Authly's refresh token structure)
      if payload.has_key?("name")
        "refresh_token"
      else
        "access_token"
      end
    end

    private def client_id
      @credentials.first
    end

    private def authorized? : Bool
      Authly.clients.authorized?(*@credentials)
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
