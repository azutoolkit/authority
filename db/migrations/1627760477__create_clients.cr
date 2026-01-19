class CreateClients < CQL::Migration(1627760477)
  def up
    schema.exec <<-SQL
      CREATE TABLE IF NOT EXISTS oauth_clients (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        client_id UUID NOT NULL UNIQUE,
        name VARCHAR(120) NOT NULL UNIQUE,
        description VARCHAR(2000),
        logo VARCHAR(120) NOT NULL,
        client_secret VARCHAR(80) NOT NULL,
        redirect_uri VARCHAR(2000) NOT NULL,
        scopes VARCHAR(4000) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
      CREATE INDEX IF NOT EXISTS idx_oauth_clients_client_id ON oauth_clients(client_id);
      CREATE INDEX IF NOT EXISTS idx_oauth_clients_name ON oauth_clients(name);
    SQL
  end

  def down
    schema.exec "DROP TABLE IF EXISTS oauth_clients;"
  end
end
