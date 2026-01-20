# Add Refresh Token Rotation Support
# Adds family_id for tracking token lineage and used_at for detecting reuse attacks
class AddRefreshTokenRotation < CQL::Migration(1737315000_i64)
  def up
    # Add family_id to track token families (all tokens descended from same original)
    schema.exec <<-SQL
      ALTER TABLE oauth_opaque_tokens
      ADD COLUMN IF NOT EXISTS family_id UUID
    SQL

    # Add used_at to track when a refresh token was exchanged for a new one
    schema.exec <<-SQL
      ALTER TABLE oauth_opaque_tokens
      ADD COLUMN IF NOT EXISTS used_at TIMESTAMP
    SQL

    # Index for family lookups (revoke all tokens in a family)
    schema.exec <<-SQL
      CREATE INDEX IF NOT EXISTS idx_oauth_opaque_tokens_family_id
      ON oauth_opaque_tokens(family_id)
    SQL
  end

  def down
    schema.exec %(ALTER TABLE oauth_opaque_tokens DROP COLUMN IF EXISTS family_id)
    schema.exec %(ALTER TABLE oauth_opaque_tokens DROP COLUMN IF EXISTS used_at)
    schema.exec %(DROP INDEX IF EXISTS idx_oauth_opaque_tokens_family_id)
  end
end
