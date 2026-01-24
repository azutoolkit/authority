# Migration to create persistent_sessions table for tracking user sessions
class CreatePersistentSessions < CQL::Migration(1768941000_i64)
  def up
    schema.exec <<-SQL
      CREATE TABLE IF NOT EXISTS persistent_sessions (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        user_id UUID NOT NULL,
        session_token TEXT NOT NULL UNIQUE,
        ip_address TEXT,
        user_agent TEXT,
        device_info TEXT,
        last_activity_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        expires_at TIMESTAMP NOT NULL,
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        revoked_at TIMESTAMP
      )
    SQL
    schema.exec %(CREATE INDEX IF NOT EXISTS idx_persistent_sessions_user_id ON persistent_sessions(user_id))
    schema.exec %(CREATE INDEX IF NOT EXISTS idx_persistent_sessions_expires_at ON persistent_sessions(expires_at))
  end

  def down
    schema.exec %(DROP TABLE IF EXISTS persistent_sessions)
  end
end
