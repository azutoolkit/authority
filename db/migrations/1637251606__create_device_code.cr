class CreateDeviceCode < CQL::Migration(1637251606)
  def up
    schema.exec <<-SQL
      CREATE TYPE IF NOT EXISTS verification AS ENUM ('allowed', 'denied', 'pending');

      CREATE TABLE IF NOT EXISTS oauth_device_codes (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        client_id VARCHAR(80) NOT NULL,
        client_name VARCHAR(80) NOT NULL,
        user_code VARCHAR(10) NOT NULL,
        verification VARCHAR(20) NOT NULL DEFAULT 'pending',
        verification_uri VARCHAR(1000) NOT NULL,
        expires_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
      CREATE INDEX IF NOT EXISTS idx_oauth_device_codes_client_id ON oauth_device_codes(client_id);
      CREATE INDEX IF NOT EXISTS idx_oauth_device_codes_user_code ON oauth_device_codes(user_code);
      CREATE INDEX IF NOT EXISTS idx_oauth_device_codes_expires_at ON oauth_device_codes(expires_at);
    SQL
  end

  def down
    schema.exec <<-SQL
      DROP TABLE IF EXISTS oauth_device_codes;
      DROP TYPE IF EXISTS verification;
    SQL
  end
end
