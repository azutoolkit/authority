# Add role and account locking fields to oauth_owners
# Supports RBAC and user account management
class AddRoleAndLockedToUsers < CQL::Migration(1768940600_i64)
  def up
    schema.exec <<-SQL
      ALTER TABLE oauth_owners
      ADD COLUMN IF NOT EXISTS role TEXT NOT NULL DEFAULT 'user',
      ADD COLUMN IF NOT EXISTS locked_at TIMESTAMP,
      ADD COLUMN IF NOT EXISTS lock_reason TEXT,
      ADD COLUMN IF NOT EXISTS failed_login_attempts INTEGER DEFAULT 0,
      ADD COLUMN IF NOT EXISTS last_login_at TIMESTAMP,
      ADD COLUMN IF NOT EXISTS last_login_ip INET
    SQL

    schema.exec <<-SQL
      CREATE INDEX IF NOT EXISTS idx_oauth_owners_role ON oauth_owners(role)
    SQL

    schema.exec <<-SQL
      CREATE INDEX IF NOT EXISTS idx_oauth_owners_locked ON oauth_owners(locked_at)
    SQL
  end

  def down
    schema.exec <<-SQL
      DROP INDEX IF EXISTS idx_oauth_owners_role
    SQL

    schema.exec <<-SQL
      DROP INDEX IF EXISTS idx_oauth_owners_locked
    SQL

    schema.exec <<-SQL
      ALTER TABLE oauth_owners
      DROP COLUMN IF EXISTS role,
      DROP COLUMN IF EXISTS locked_at,
      DROP COLUMN IF EXISTS lock_reason,
      DROP COLUMN IF EXISTS failed_login_attempts,
      DROP COLUMN IF EXISTS last_login_at,
      DROP COLUMN IF EXISTS last_login_ip
    SQL
  end
end
