# Add metadata columns to oauth_clients for admin management
# Adds policy_url, tos_url, owner_id, and is_confidential fields
class AddMetadataToClients < CQL::Migration(1768940500_i64)
  def up
    schema.exec <<-SQL
      ALTER TABLE oauth_clients
      ADD COLUMN IF NOT EXISTS policy_url TEXT,
      ADD COLUMN IF NOT EXISTS tos_url TEXT,
      ADD COLUMN IF NOT EXISTS owner_id UUID,
      ADD COLUMN IF NOT EXISTS is_confidential BOOLEAN DEFAULT TRUE
    SQL

    schema.exec <<-SQL
      CREATE INDEX IF NOT EXISTS idx_oauth_clients_owner ON oauth_clients(owner_id)
    SQL
  end

  def down
    schema.exec <<-SQL
      DROP INDEX IF EXISTS idx_oauth_clients_owner
    SQL

    schema.exec <<-SQL
      ALTER TABLE oauth_clients
      DROP COLUMN IF EXISTS policy_url,
      DROP COLUMN IF EXISTS tos_url,
      DROP COLUMN IF EXISTS owner_id,
      DROP COLUMN IF EXISTS is_confidential
    SQL
  end
end
