# Account Recovery Tokens Table Migration
# Stores tokens for password reset and email verification
# Tokens are single-use and time-limited for security
class CreateRecoveryTokens < CQL::Migration(1737314000_i64)
  def up
    schema.exec <<-SQL
      CREATE TABLE IF NOT EXISTS oauth_recovery_tokens (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        token TEXT NOT NULL UNIQUE,
        token_type TEXT NOT NULL,
        user_id TEXT NOT NULL,
        expires_at TIMESTAMP NOT NULL,
        used_at TIMESTAMP,
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    SQL
    schema.exec %(CREATE INDEX IF NOT EXISTS idx_oauth_recovery_tokens_token ON oauth_recovery_tokens(token))
    schema.exec %(CREATE INDEX IF NOT EXISTS idx_oauth_recovery_tokens_token_type ON oauth_recovery_tokens(token_type))
    schema.exec %(CREATE INDEX IF NOT EXISTS idx_oauth_recovery_tokens_user_id ON oauth_recovery_tokens(user_id))
    schema.exec %(CREATE INDEX IF NOT EXISTS idx_oauth_recovery_tokens_expires_at ON oauth_recovery_tokens(expires_at))
  end

  def down
    schema.exec %(DROP TABLE IF EXISTS oauth_recovery_tokens)
  end
end
