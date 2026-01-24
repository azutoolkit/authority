# Add password policy and MFA fields to oauth_owners
# Supports password history, expiry, and multi-factor authentication
class AddPasswordPolicyAndMfaToUsers < CQL::Migration(1768940900_i64)
  def up
    schema.exec <<-SQL
      ALTER TABLE oauth_owners
      ADD COLUMN IF NOT EXISTS password_changed_at TIMESTAMP,
      ADD COLUMN IF NOT EXISTS password_history TEXT,
      ADD COLUMN IF NOT EXISTS mfa_enabled BOOLEAN DEFAULT FALSE,
      ADD COLUMN IF NOT EXISTS totp_secret TEXT,
      ADD COLUMN IF NOT EXISTS backup_codes TEXT
    SQL

    # Index for MFA-enabled users
    schema.exec <<-SQL
      CREATE INDEX IF NOT EXISTS idx_oauth_owners_mfa_enabled ON oauth_owners(mfa_enabled) WHERE mfa_enabled = TRUE
    SQL
  end

  def down
    schema.exec <<-SQL
      DROP INDEX IF EXISTS idx_oauth_owners_mfa_enabled
    SQL

    schema.exec <<-SQL
      ALTER TABLE oauth_owners
      DROP COLUMN IF EXISTS password_changed_at,
      DROP COLUMN IF EXISTS password_history,
      DROP COLUMN IF EXISTS mfa_enabled,
      DROP COLUMN IF EXISTS totp_secret,
      DROP COLUMN IF EXISTS backup_codes
    SQL
  end
end
