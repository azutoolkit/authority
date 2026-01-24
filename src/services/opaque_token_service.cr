# Opaque Token Service
# Generates and manages opaque (non-JWT) tokens
# Provides immediate revocation and enhanced security
module Authority
  class OpaqueTokenService
    ACCESS_TTL  = ENV.fetch("ACCESS_TOKEN_TTL", "60").to_i.minutes
    REFRESH_TTL = ENV.fetch("REFRESH_TTL", "1440").to_i.minutes

    def self.create_tokens(
      client_id : String,
      scope : String,
      user_id : String? = nil,
      id_token : String? = nil
    ) : OpaqueTokenResponse
      access_token = OpaqueToken.create_access_token(
        client_id: client_id,
        scope: scope,
        user_id: user_id,
        ttl: ACCESS_TTL
      )

      refresh_token = OpaqueToken.create_refresh_token(
        client_id: client_id,
        scope: scope,
        user_id: user_id,
        ttl: REFRESH_TTL
      )

      OpaqueTokenResponse.new(
        access_token: access_token.token,
        refresh_token: refresh_token.token,
        expires_in: ACCESS_TTL.total_seconds.to_i64,
        scope: scope,
        id_token: id_token
      )
    end

    # Refresh tokens with rotation - creates new access and refresh tokens
    # Implements refresh token rotation per OAuth 2.0 Security Best Practices
    def self.refresh(refresh_token_string : String, client_id : String) : OpaqueTokenResponse?
      refresh_token = OpaqueToken.find_by(token: refresh_token_string)
      return nil unless refresh_token
      return nil unless refresh_token.token_type == "refresh_token"
      return nil unless refresh_token.client_id == client_id
      return nil if refresh_token.expired?
      return nil if refresh_token.revoked?

      # SECURITY: Detect refresh token reuse attack
      # If token was already used, an attacker may have stolen it
      # Revoke the entire token family to protect the user
      if refresh_token.used?
        if family_id = refresh_token.family_id
          OpaqueToken.revoke_family!(family_id)
        end
        return nil
      end

      # Rotate the refresh token - mark old as used, create new one
      new_refresh_token = refresh_token.rotate!(REFRESH_TTL)
      return nil unless new_refresh_token

      # Create new access token with same scope and user
      access_token = OpaqueToken.create_access_token(
        client_id: refresh_token.client_id,
        scope: refresh_token.scope,
        user_id: refresh_token.user_id,
        ttl: ACCESS_TTL
      )

      OpaqueTokenResponse.new(
        access_token: access_token.token,
        refresh_token: new_refresh_token.token, # Return NEW refresh token
        expires_in: ACCESS_TTL.total_seconds.to_i64,
        scope: refresh_token.scope,
        id_token: nil
      )
    end

    # Introspect a token (works for both access and refresh tokens)
    def self.introspect(token_string : String) : OpaqueTokenInfo?
      token = OpaqueToken.find_by(token: token_string)
      return nil unless token

      OpaqueTokenInfo.new(
        active: token.active?,
        client_id: token.client_id,
        scope: token.scope,
        exp: token.expires_at.to_unix,
        token_type: token.token_type,
        user_id: token.user_id
      )
    end

    # Revoke a token
    def self.revoke(token_string : String) : Bool
      OpaqueToken.revoke_by_token!(token_string)
    end
  end

  # Response struct for opaque token generation (matches OAuth2 spec)
  struct OpaqueTokenResponse
    include JSON::Serializable

    getter access_token : String
    getter token_type : String = "Bearer"
    getter expires_in : Int64

    @[JSON::Field(emit_null: false)]
    getter refresh_token : String?

    @[JSON::Field(emit_null: false)]
    getter scope : String?

    @[JSON::Field(emit_null: false)]
    getter id_token : String?

    def initialize(
      @access_token : String,
      @refresh_token : String? = nil,
      @expires_in : Int64 = 3600,
      @scope : String? = nil,
      @id_token : String? = nil
    )
    end
  end

  # Token info for introspection response
  struct OpaqueTokenInfo
    include JSON::Serializable

    getter? active : Bool
    getter client_id : String
    getter scope : String
    getter exp : Int64
    getter token_type : String

    @[JSON::Field(emit_null: false)]
    getter user_id : String?

    def initialize(
      @active : Bool,
      @client_id : String,
      @scope : String,
      @exp : Int64,
      @token_type : String,
      @user_id : String? = nil
    )
    end
  end
end
