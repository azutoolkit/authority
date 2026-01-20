# Add redirect_uris column for multi-redirect URI support
# Stores comma-separated list of redirect URIs per RFC 7591
class AddRedirectUris < CQL::Migration(1768940167_i64)
  def up
    schema.exec <<-SQL
      ALTER TABLE oauth_clients
      ADD COLUMN IF NOT EXISTS redirect_uris TEXT
    SQL

    # Migrate existing redirect_uri values to redirect_uris
    schema.exec <<-SQL
      UPDATE oauth_clients
      SET redirect_uris = redirect_uri
      WHERE redirect_uris IS NULL
    SQL
  end

  def down
    schema.exec <<-SQL
      ALTER TABLE oauth_clients
      DROP COLUMN IF EXISTS redirect_uris
    SQL
  end
end
