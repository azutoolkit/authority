require "pg"
require "cql"
require "crypto/bcrypt/password"

# CQL Schema Definition
# https://github.com/azutoolkit/cql
AuthorityDB = CQL::Schema.define(
  :authority,
  ENV["DATABASE_URL"],
  CQL::Adapter::Postgres
) do
  table :oauth_owners do
    primary :id, UUID
    text :username, null: false, index: true, unique: true
    text :encrypted_password, null: false
    text :first_name, null: false
    text :last_name, null: false
    text :email, null: false
    boolean :email_verified, null: false, default: false
    text :scope, null: false
    timestamps
  end

  table :oauth_clients do
    primary :id, UUID
    column :client_id, UUID, index: true, unique: true
    text :name, null: false, index: true, unique: true
    text :description, null: true
    text :logo, null: false
    text :client_secret, null: false
    text :redirect_uri, null: false
    text :scopes, null: false
    timestamps
  end

  table :oauth_device_codes do
    primary :id, UUID
    text :client_id, null: false, index: true
    text :client_name, null: false
    text :user_code, null: false, index: true
    text :verification, null: false
    text :verification_uri, null: false
    timestamp :expires_at, null: false, index: true
    timestamps
  end

  table :oauth_revoked_tokens do
    primary :id, UUID
    text :jti, null: false, index: true, unique: true
    text :client_id, null: false, index: true
    text :token_type, null: false
    timestamp :revoked_at, null: false
    timestamp :expires_at, null: false, index: true
    timestamps
  end
end
