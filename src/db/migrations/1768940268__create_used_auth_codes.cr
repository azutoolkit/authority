# Create table to track used authorization codes for single-use enforcement
# Per OAuth 2.0 spec, authorization codes must be single-use
class CreateUsedAuthCodes < CQL::Migration(1768940268_i64)
  def up
    schema.exec <<-SQL
      CREATE TABLE IF NOT EXISTS oauth_used_auth_codes (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        code_hash TEXT NOT NULL UNIQUE,
        client_id TEXT NOT NULL,
        used_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    SQL

    # Index for quick lookups and cleanup
    schema.exec <<-SQL
      CREATE INDEX IF NOT EXISTS idx_used_auth_codes_hash ON oauth_used_auth_codes(code_hash)
    SQL
    schema.exec <<-SQL
      CREATE INDEX IF NOT EXISTS idx_used_auth_codes_used_at ON oauth_used_auth_codes(used_at)
    SQL
  end

  def down
    schema.exec %(DROP TABLE IF EXISTS oauth_used_auth_codes)
  end
end
