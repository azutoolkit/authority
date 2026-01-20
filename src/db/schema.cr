AppDB = CQL::Schema.define(
  :app_db,
  adapter: CQL::Adapter::Postgres,
  uri: "postgres://eperez:@localhost:5432/authority_db?initial_pool_size=10&checkout_timeout=3") do
  table :clients do
    primary :id, String
    text :client_id, null: true, default: "uuid_generate_v4()"
    text :name
    text :description, null: true
    text :logo
    text :client_secret
    text :redirect_uri
    text :scopes
    timestamps
  end

  table :cql_schema_migrations do
    primary :id, Int32
    text :name
    bigint :version
    timestamps
  end

  table :oauth_clients do
    primary :id, String
    text :client_id
    text :name
    text :description, null: true
    text :logo
    text :client_secret
    text :redirect_uri
    text :scopes
    timestamps
  end

  table :oauth_device_codes do
    primary :id, String
    text :client_id
    text :client_name
    text :user_code
    text :verification
    text :verification_uri
    text :expires_at, null: true, default: "CURRENT_TIMESTAMP"
    timestamps
  end

  table :oauth_opaque_tokens do
    primary :id, String
    text :token
    text :token_type
    text :client_id
    text :user_id, null: true
    text :scope
    timestamp :expires_at
    timestamp :revoked_at, null: true
    timestamps
  end

  table :oauth_owners do
    primary :id, String
    text :username
    text :encrypted_password
    text :first_name
    text :last_name
    text :email
    boolean :email_verified, default: "false"
    text :scope
    timestamps
  end

  table :oauth_recovery_tokens do
    primary :id, String
    text :token
    text :token_type
    text :user_id
    timestamp :expires_at
    timestamp :used_at, null: true
    timestamps
  end

  table :oauth_revoked_tokens do
    primary :id, String
    text :jti
    text :client_id
    text :token_type
    timestamp :revoked_at
    timestamp :expires_at
    timestamps
  end

  table :owners do
    primary :id, String
    text :username
    text :encrypted_password
    text :first_name
    text :last_name
    text :email
    boolean :email_verified
    text :scope
    timestamps
  end

end
