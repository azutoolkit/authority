# OAuth Device Authorization Grant Table Migration (RFC 8628)
# Stores device codes for the device authorization flow
class CreateDeviceCode < CQL::Migration(1637251606)
  def up
    # Create custom ENUM type for verification status
    schema.exec %(CREATE TYPE IF NOT EXISTS verification AS ENUM ('allowed', 'denied', 'pending');)

    schema.table :oauth_device_codes do
      primary :id, UUID
      text :client_id, null: false, index: true
      text :client_name, null: false
      text :user_code, null: false, index: true
      text :verification, null: false
      text :verification_uri, null: false
      timestamp :expires_at, null: false, index: true
      timestamps
    end
    schema.oauth_device_codes.create!
  end

  def down
    schema.oauth_device_codes.drop!
    schema.exec %(DROP TYPE IF EXISTS verification;)
  end
end
