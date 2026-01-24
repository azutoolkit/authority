# Migration to create settings table for system configuration
class CreateSettings < CQL::Migration(1768941100_i64)
  def up
    schema.exec <<-SQL
      CREATE TABLE IF NOT EXISTS settings (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        key TEXT NOT NULL UNIQUE,
        value TEXT,
        category TEXT NOT NULL,
        description TEXT,
        updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_by TEXT
      )
    SQL
    schema.exec %(CREATE INDEX IF NOT EXISTS idx_settings_category ON settings(category))
  end

  def down
    schema.exec %(DROP TABLE IF EXISTS settings)
  end
end
