# OAuth Clients Table Migration
# Stores registered OAuth client applications
class CreateClients < CQL::Migration(1627760477_i64)
  def up
    schema.exec <<-SQL
      CREATE TABLE IF NOT EXISTS oauth_clients (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        client_id UUID NOT NULL UNIQUE,
        name TEXT NOT NULL UNIQUE,
        description TEXT,
        logo TEXT NOT NULL,
        client_secret TEXT NOT NULL,
        redirect_uri TEXT NOT NULL,
        scopes TEXT NOT NULL,
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    SQL
    schema.exec %(CREATE INDEX IF NOT EXISTS idx_oauth_clients_client_id ON oauth_clients(client_id))
    schema.exec %(CREATE INDEX IF NOT EXISTS idx_oauth_clients_name ON oauth_clients(name))
  end

  def down
    schema.exec %(DROP TABLE IF EXISTS oauth_clients)
  end
end
