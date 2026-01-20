# Opaque Token Model
# Stores non-JWT tokens with server-side metadata
# Provides immediate revocation and enhanced security
module Authority
  class OpaqueToken
    include CQL::ActiveRecord::Model(UUID)
    db_context AuthorityDB, :oauth_opaque_tokens

    property token : String = ""
    property token_type : String = "access_token"
    property client_id : String = ""
    property user_id : String?
    property scope : String = ""
    property expires_at : Time = Time.utc
    property revoked_at : Time?
    property created_at : Time?
    property updated_at : Time?

    TOKEN_LENGTH = 64 # 256 bits of entropy

    before_save :generate_token

    def initialize
    end

    private def generate_token
      @token = Random::Secure.hex(TOKEN_LENGTH / 2) if @token.empty?
      true
    end

    # Check if token is active (not expired and not revoked)
    def active? : Bool
      !expired? && !revoked?
    end

    # Check if token is expired
    def expired? : Bool
      Time.utc > expires_at
    end

    # Check if token is revoked
    def revoked? : Bool
      !revoked_at.nil?
    end

    # Revoke this token
    def revoke!
      @revoked_at = Time.utc
      update!
    end

    # Generate an access token for a client
    def self.create_access_token(
      client_id : String,
      scope : String,
      user_id : String? = nil,
      ttl : Time::Span = 1.hour
    ) : OpaqueToken
      token = OpaqueToken.new
      token.token_type = "access_token"
      token.client_id = client_id
      token.user_id = user_id
      token.scope = scope
      token.expires_at = ttl.from_now
      token.save!
      token
    end

    # Generate a refresh token for a client
    def self.create_refresh_token(
      client_id : String,
      scope : String,
      user_id : String? = nil,
      ttl : Time::Span = 24.hours
    ) : OpaqueToken
      token = OpaqueToken.new
      token.token_type = "refresh_token"
      token.client_id = client_id
      token.user_id = user_id
      token.scope = scope
      token.expires_at = ttl.from_now
      token.save!
      token
    end

    # Find an active token by its string value
    def self.find_active(token_string : String) : OpaqueToken?
      token = find_by(token: token_string)
      return nil unless token
      return nil if token.expired?
      return nil if token.revoked?
      token
    end

    # Find an active token by its string value, raise if not found
    def self.find_active!(token_string : String) : OpaqueToken
      find_active(token_string) || raise "Token not found or inactive"
    end

    # Revoke a token by its string value
    def self.revoke_by_token!(token_string : String) : Bool
      token = find_by(token: token_string)
      return false unless token
      return true if token.revoked? # Already revoked
      token.revoke!
      true
    end

    # Revoke all tokens for a client
    def self.revoke_all_for_client!(client_id : String)
      where(client_id: client_id).each do |token|
        token.revoke! unless token.revoked?
      end
    end

    # Revoke all tokens for a user
    def self.revoke_all_for_user!(user_id : String)
      where(user_id: user_id).each do |token|
        token.revoke! unless token.revoked?
      end
    end

    # Cleanup expired tokens (for maintenance)
    def self.cleanup_expired!
      OpaqueToken.where("expires_at < ?", Time.utc).delete_all
    end

    # Check if a token string looks like an opaque token (vs JWT)
    def self.opaque?(token_string : String) : Bool
      # JWTs have 3 base64-encoded parts separated by dots
      # Opaque tokens are just hex strings
      !token_string.includes?(".")
    end

    # Get token info for introspection response
    def token_info : NamedTuple(active: Bool, client_id: String, scope: String, exp: Int64, token_type: String, user_id: String?)
      {
        active:     active?,
        client_id:  client_id,
        scope:      scope,
        exp:        expires_at.to_unix,
        token_type: token_type,
        user_id:    user_id,
      }
    end
  end
end
