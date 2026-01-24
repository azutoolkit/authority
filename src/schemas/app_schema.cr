AppSchema = CQL::Schema.define(
  :app_schema,
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

  table :oauth_audit_logs do
    primary :id, String
    text :actor_id
    text :actor_email
    text :action
    text :resource_type
    text :resource_id, null: true
    text :resource_name, null: true
    json :changes, null: true
    text :ip_address, null: true
    text :user_agent, null: true
    timestamp :created_at, null: true, default: "CURRENT_TIMESTAMP"
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
    text :redirect_uris, null: true
    text :policy_url, null: true
    text :tos_url, null: true
    text :owner_id, null: true
    boolean :is_confidential, null: true, default: "true"
    timestamps
  end

  table :oauth_consents do
    primary :id, String
    text :user_id
    text :client_id
    text :scopes
    timestamp :granted_at, default: "CURRENT_TIMESTAMP"
    timestamp :revoked_at, null: true
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
    text :family_id, null: true
    timestamp :used_at, null: true
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
    text :role, default: "'user'::text"
    timestamp :locked_at, null: true
    text :lock_reason, null: true
    integer :failed_login_attempts, null: true, default: "0"
    timestamp :last_login_at, null: true
    text :last_login_ip, null: true
    timestamp :password_changed_at, null: true
    text :password_history, null: true
    boolean :mfa_enabled, null: true, default: "false"
    text :totp_secret, null: true
    text :backup_codes, null: true
    timestamps
  end

  table :oauth_par_requests do
    primary :id, String
    text :request_uri
    text :client_id
    text :redirect_uri
    text :response_type
    text :scope, null: true
    text :state, null: true
    text :code_challenge, null: true
    text :code_challenge_method, null: true
    text :nonce, null: true
    boolean :used, default: "false"
    timestamp :expires_at
    timestamp :created_at, default: "CURRENT_TIMESTAMP"
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

  table :oauth_scopes do
    primary :id, String
    text :name
    text :display_name
    text :description, null: true
    boolean :is_default, null: true, default: "false"
    boolean :is_system, null: true, default: "false"
    timestamps
  end

  table :oauth_used_auth_codes do
    primary :id, String
    text :code_hash
    text :client_id
    timestamp :used_at, default: "CURRENT_TIMESTAMP"
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

  table :persistent_sessions do
    primary :id, String
    text :user_id
    text :session_token
    text :ip_address, null: true
    text :user_agent, null: true
    text :device_info, null: true
    timestamp :last_activity_at, default: "CURRENT_TIMESTAMP"
    timestamp :expires_at
    timestamp :created_at, default: "CURRENT_TIMESTAMP"
    timestamp :revoked_at, null: true
  end

  table :seed_versions do
    primary :id, Int32
    text :seed_name
    timestamp :executed_at, default: "CURRENT_TIMESTAMP"
  end

  table :settings do
    primary :id, String
    text :key
    text :value, null: true
    text :category
    text :description, null: true
    timestamp :updated_at, default: "CURRENT_TIMESTAMP"
    text :updated_by, null: true
  end

end
