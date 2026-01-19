# Token Revocation Table Migration (RFC 7009)
# Stores revoked token JTIs to enable token revocation for stateless JWTs
class CreateRevokedTokens < CQL::Migration(1737312000)
  def up
    schema.table :oauth_revoked_tokens do
      primary :id, UUID
      text :jti, null: false, index: true, unique: true
      text :client_id, null: false, index: true
      text :token_type, null: false
      timestamp :revoked_at, null: false
      timestamp :expires_at, null: false, index: true
      timestamps
    end
    schema.oauth_revoked_tokens.create!
  end

  def down
    schema.oauth_revoked_tokens.drop!
  end
end
