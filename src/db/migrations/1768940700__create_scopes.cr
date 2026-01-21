# Create oauth_scopes table for scope management
# Allows defining and managing OAuth scopes with metadata
class CreateScopes < CQL::Migration(1768940700_i64)
  def up
    schema.exec <<-SQL
      CREATE TABLE IF NOT EXISTS oauth_scopes (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        name TEXT NOT NULL UNIQUE,
        display_name TEXT NOT NULL,
        description TEXT,
        is_default BOOLEAN DEFAULT FALSE,
        is_system BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    SQL

    schema.exec <<-SQL
      CREATE INDEX IF NOT EXISTS idx_oauth_scopes_name ON oauth_scopes(name)
    SQL

    schema.exec <<-SQL
      CREATE INDEX IF NOT EXISTS idx_oauth_scopes_is_default ON oauth_scopes(is_default)
    SQL

    # Seed OIDC standard scopes as system scopes
    schema.exec <<-SQL
      INSERT INTO oauth_scopes (name, display_name, description, is_default, is_system)
      VALUES
        ('openid', 'OpenID', 'Access to your identity', true, true),
        ('profile', 'Profile', 'Access to your profile information', false, true),
        ('email', 'Email', 'Access to your email address', false, true),
        ('offline_access', 'Offline Access', 'Access when you are not present', false, true)
      ON CONFLICT (name) DO NOTHING
    SQL
  end

  def down
    schema.exec <<-SQL
      DROP INDEX IF EXISTS idx_oauth_scopes_name
    SQL

    schema.exec <<-SQL
      DROP INDEX IF EXISTS idx_oauth_scopes_is_default
    SQL

    schema.exec <<-SQL
      DROP TABLE IF EXISTS oauth_scopes
    SQL
  end
end
