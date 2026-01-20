# OAuth Device Authorization Grant Table Migration (RFC 8628)
# Stores device codes for the device authorization flow
class CreateDeviceCode < CQL::Migration(1637251606_i64)
  def up
    schema.exec <<-SQL
      DO $$ BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'verification') THEN
          CREATE TYPE verification AS ENUM ('allowed', 'denied', 'pending');
        END IF;
      END $$
    SQL
    schema.exec <<-SQL
      CREATE TABLE IF NOT EXISTS oauth_device_codes (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        client_id TEXT NOT NULL,
        client_name TEXT NOT NULL,
        user_code TEXT NOT NULL,
        verification TEXT NOT NULL,
        verification_uri TEXT NOT NULL,
        expires_at TIMESTAMP NOT NULL,
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    SQL
    schema.exec %(CREATE INDEX IF NOT EXISTS idx_oauth_device_codes_client_id ON oauth_device_codes(client_id))
    schema.exec %(CREATE INDEX IF NOT EXISTS idx_oauth_device_codes_user_code ON oauth_device_codes(user_code))
    schema.exec %(CREATE INDEX IF NOT EXISTS idx_oauth_device_codes_expires_at ON oauth_device_codes(expires_at))
  end

  def down
    schema.exec %(DROP TABLE IF EXISTS oauth_device_codes)
    schema.exec %(DROP TYPE IF EXISTS verification)
  end
end
