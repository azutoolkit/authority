# Opaque Tokens Table Migration
# Stores non-JWT tokens with server-side metadata for enhanced security
# Unlike JWTs, opaque tokens require server-side lookup for validation
class CreateOpaqueTokens < CQL::Migration(1737313000_i64)
  def up
    schema.exec <<-SQL
      CREATE TABLE IF NOT EXISTS oauth_opaque_tokens (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        token TEXT NOT NULL UNIQUE,
        token_type TEXT NOT NULL,
        client_id TEXT NOT NULL,
        user_id TEXT,
        scope TEXT NOT NULL,
        expires_at TIMESTAMP NOT NULL,
        revoked_at TIMESTAMP,
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    SQL
    schema.exec %(CREATE INDEX IF NOT EXISTS idx_oauth_opaque_tokens_token ON oauth_opaque_tokens(token))
    schema.exec %(CREATE INDEX IF NOT EXISTS idx_oauth_opaque_tokens_token_type ON oauth_opaque_tokens(token_type))
    schema.exec %(CREATE INDEX IF NOT EXISTS idx_oauth_opaque_tokens_client_id ON oauth_opaque_tokens(client_id))
    schema.exec %(CREATE INDEX IF NOT EXISTS idx_oauth_opaque_tokens_user_id ON oauth_opaque_tokens(user_id))
    schema.exec %(CREATE INDEX IF NOT EXISTS idx_oauth_opaque_tokens_expires_at ON oauth_opaque_tokens(expires_at))
  end

  def down
    schema.exec %(DROP TABLE IF EXISTS oauth_opaque_tokens)
  end
end
