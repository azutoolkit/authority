module Authority
  class RevokedToken
    include CQL::ActiveRecord::Model(UUID)
    db_context AuthorityDB, :oauth_revoked_tokens

    property jti : String = ""
    property client_id : String = ""
    property token_type : String = "access_token"
    property revoked_at : Time = Time.utc
    property expires_at : Time = Time.utc
    property created_at : Time?
    property updated_at : Time?

    before_save :set_revoked_at

    def initialize
    end

    private def set_revoked_at
      @revoked_at = Time.utc
      true
    end

    # Check if a token with the given JTI has been revoked
    def self.revoked?(jti : String) : Bool
      exists?(jti: jti)
    end

    # Revoke a token by JTI
    def self.revoke!(jti : String, client_id : String, token_type : String, expires_at : Time)
      return if revoked?(jti) # Already revoked

      token = RevokedToken.new
      token.jti = jti
      token.client_id = client_id
      token.token_type = token_type
      token.expires_at = expires_at
      token.save!
      token
    end

    # Cleanup expired revoked tokens (tokens that have passed their original expiration)
    def self.cleanup_expired!
      RevokedToken
        .where { oauth_revoked_tokens.expires_at < Time.utc }
        .delete_all
    end
  end
end
