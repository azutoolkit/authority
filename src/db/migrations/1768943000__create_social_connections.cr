# Migration to create social_connections table for OAuth social login federation
class CreateSocialConnections < CQL::Migration(1768943000_i64)
  def up
    schema.exec <<-SQL
      CREATE TABLE IF NOT EXISTS social_connections (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        user_id UUID NOT NULL REFERENCES oauth_owners(id) ON DELETE CASCADE,
        provider VARCHAR(50) NOT NULL,
        provider_user_id VARCHAR(255) NOT NULL,
        email VARCHAR(255),
        name VARCHAR(255),
        avatar_url TEXT,
        access_token TEXT,
        refresh_token TEXT,
        token_expires_at TIMESTAMP,
        raw_info TEXT,
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(provider, provider_user_id)
      )
    SQL

    schema.exec %(CREATE INDEX IF NOT EXISTS idx_social_connections_user_id ON social_connections(user_id))
    schema.exec %(CREATE INDEX IF NOT EXISTS idx_social_connections_provider_email ON social_connections(provider, email))
    schema.exec %(CREATE INDEX IF NOT EXISTS idx_social_connections_provider ON social_connections(provider))
  end

  def down
    schema.exec %(DROP TABLE IF EXISTS social_connections)
  end
end
