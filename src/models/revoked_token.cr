module Authority
  class RevokedToken
    include CQL::ActiveRecord::Model(String)
    db_context AuthorityDB, :oauth_revoked_tokens

    property id : String?
    property jti : String = ""
    property client_id : String = ""
    property token_type : String = "access_token"
    property revoked_at : Time = Time.utc
    property expires_at : Time = Time.utc
    property created_at : Time?
    property updated_at : Time?

    # Initialize with default values for new records
    def initialize
    end

    # Override create! to handle UUID primary keys
    def create!
      validate!
      @id ||= UUID.random.to_s
      @revoked_at = Time.utc if @revoked_at == Time.utc
      attrs = attributes
      CQL::Insert
        .new(RevokedToken.schema)
        .into(RevokedToken.table)
        .values(attrs)
        .commit
      self
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
      RevokedToken.where("expires_at < ?", Time.utc).delete_all
    end
  end
end
