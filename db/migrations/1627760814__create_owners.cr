class CreateOwners < CQL::Migration(1627760814)
  def up
    schema.exec <<-SQL
      CREATE TABLE IF NOT EXISTS oauth_owners (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        username VARCHAR(80) NOT NULL UNIQUE,
        encrypted_password VARCHAR(255) NOT NULL,
        first_name VARCHAR(80) NOT NULL,
        last_name VARCHAR(80) NOT NULL,
        email VARCHAR(80) NOT NULL,
        email_verified BOOLEAN NOT NULL DEFAULT FALSE,
        scope VARCHAR(4000) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
      CREATE INDEX IF NOT EXISTS idx_oauth_owners_username ON oauth_owners(username);
    SQL
  end

  def down
    schema.exec "DROP TABLE IF EXISTS oauth_owners;"
  end
end
