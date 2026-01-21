
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
    text :role, null: false, default: "user", index: true
    timestamp :locked_at, null: true, index: true
    text :lock_reason, null: true
    integer :failed_login_attempts, null: false, default: 0
    timestamp :last_login_at, null: true
    text :last_login_ip, null: true
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
    text :redirect_uris, null: true
    text :scopes, null: false
    text :policy_url, null: true
    text :tos_url, null: true
    column :owner_id, UUID, null: true, index: true
    boolean :is_confidential, null: false, default: true
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

  # Opaque Tokens Table - stores non-JWT tokens with server-side metadata
  table :oauth_opaque_tokens do
    primary :id, UUID
    text :token, null: false, index: true, unique: true
    text :token_type, null: false, index: true
    text :client_id, null: false, index: true
    text :user_id, null: true, index: true
    text :scope, null: false
    timestamp :expires_at, null: false, index: true
    timestamp :revoked_at, null: true
    column :family_id, UUID, null: true, index: true
    timestamp :used_at, null: true
    timestamps
  end

  # Account Recovery Tokens Table - password reset and email verification
  table :oauth_recovery_tokens do
    primary :id, UUID
    text :token, null: false, index: true, unique: true
    text :token_type, null: false, index: true
    text :user_id, null: false, index: true
    timestamp :expires_at, null: false, index: true
    timestamp :used_at, null: true
    timestamps
  end

  # OAuth Scopes Table - manages OAuth scopes with metadata
  table :oauth_scopes do
    primary :id, UUID
    text :name, null: false, index: true, unique: true
    text :display_name, null: false
    text :description, null: true
    boolean :is_default, null: false, default: false, index: true
    boolean :is_system, null: false, default: false
    timestamps
  end

  # Audit Logs Table - tracks admin actions
  table :oauth_audit_logs do
    primary :id, UUID
    column :actor_id, UUID, null: false, index: true
    text :actor_email, null: false
    text :action, null: false, index: true
    text :resource_type, null: false
    column :resource_id, UUID, null: true
    text :resource_name, null: true
    text :changes, null: true
    text :ip_address, null: true
    text :user_agent, null: true
    timestamp :created_at, null: true, index: true
  end

  # Pushed Authorization Requests Table - stores PAR requests
  table :oauth_par_requests do
    primary :id, String
    text :request_uri, null: false, index: true
    text :client_id, null: false, index: true
    text :redirect_uri, null: false
    text :response_type, null: false
    text :scope, null: true
    text :state, null: true
    text :code_challenge, null: true
    text :code_challenge_method, null: true
    text :nonce, null: true
    boolean :used, null: false, default: false
    timestamp :expires_at, null: false, index: true
    timestamp :created_at, null: true
  end

  # Used Authorization Codes Table - tracks used auth codes to prevent replay
  table :oauth_used_auth_codes do
    primary :id, String
    text :code_hash, null: false, index: true, unique: true
    text :client_id, null: false, index: true
    timestamp :used_at, null: true
  end
end
