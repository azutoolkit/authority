# User Consent Table Migration
# Stores user consent records for OAuth2 scope grants
class CreateConsents < CQL::Migration(1737316000_i64)
  def up
    schema.exec <<-SQL
      CREATE TABLE IF NOT EXISTS oauth_consents (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        user_id UUID NOT NULL,
        client_id TEXT NOT NULL,
        scopes TEXT NOT NULL,
        granted_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        revoked_at TIMESTAMP,
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        CONSTRAINT unique_user_client UNIQUE (user_id, client_id)
      )
    SQL
    schema.exec %(CREATE INDEX IF NOT EXISTS idx_oauth_consents_user_id ON oauth_consents(user_id))
    schema.exec %(CREATE INDEX IF NOT EXISTS idx_oauth_consents_client_id ON oauth_consents(client_id))
  end

  def down
    schema.exec %(DROP TABLE IF EXISTS oauth_consents)
  end
end
