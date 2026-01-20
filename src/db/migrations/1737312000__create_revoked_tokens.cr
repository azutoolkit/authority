# Token Revocation Table Migration (RFC 7009)
# Stores revoked token JTIs to enable token revocation for stateless JWTs
class CreateRevokedTokens < CQL::Migration(1737312000_i64)
  def up
    schema.exec <<-SQL
      CREATE TABLE IF NOT EXISTS oauth_revoked_tokens (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        jti TEXT NOT NULL UNIQUE,
        client_id TEXT NOT NULL,
        token_type TEXT NOT NULL,
        revoked_at TIMESTAMP NOT NULL,
        expires_at TIMESTAMP NOT NULL,
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    SQL
    schema.exec %(CREATE INDEX IF NOT EXISTS idx_oauth_revoked_tokens_jti ON oauth_revoked_tokens(jti))
    schema.exec %(CREATE INDEX IF NOT EXISTS idx_oauth_revoked_tokens_client_id ON oauth_revoked_tokens(client_id))
    schema.exec %(CREATE INDEX IF NOT EXISTS idx_oauth_revoked_tokens_expires_at ON oauth_revoked_tokens(expires_at))
  end

  def down
    schema.exec %(DROP TABLE IF EXISTS oauth_revoked_tokens)
  end
end
