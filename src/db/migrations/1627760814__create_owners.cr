# OAuth Resource Owners (Users) Table Migration
# Stores user accounts for OAuth authentication
class CreateOwners < CQL::Migration(1627760814_i64)
  def up
    schema.exec <<-SQL
      CREATE TABLE IF NOT EXISTS oauth_owners (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        username TEXT NOT NULL UNIQUE,
        encrypted_password TEXT NOT NULL,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        email TEXT NOT NULL,
        email_verified BOOLEAN NOT NULL DEFAULT FALSE,
        scope TEXT NOT NULL,
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    SQL
    schema.exec %(CREATE INDEX IF NOT EXISTS idx_oauth_owners_username ON oauth_owners(username))
  end

  def down
    schema.exec %(DROP TABLE IF EXISTS oauth_owners)
  end
end
