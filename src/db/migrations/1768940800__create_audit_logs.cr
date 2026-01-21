# Migration to create oauth_audit_logs table for admin action tracking
class CreateAuditLogs < CQL::Migration(1768940800_i64)
  def up
    schema.exec <<-SQL
      CREATE TABLE IF NOT EXISTS oauth_audit_logs (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        actor_id UUID NOT NULL,
        actor_email TEXT NOT NULL,
        action TEXT NOT NULL,
        resource_type TEXT NOT NULL,
        resource_id UUID,
        resource_name TEXT,
        changes JSONB,
        ip_address INET,
        user_agent TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    SQL

    # Create indexes for efficient querying
    schema.exec <<-SQL
      CREATE INDEX IF NOT EXISTS idx_audit_logs_actor ON oauth_audit_logs(actor_id)
    SQL

    schema.exec <<-SQL
      CREATE INDEX IF NOT EXISTS idx_audit_logs_resource ON oauth_audit_logs(resource_type, resource_id)
    SQL

    schema.exec <<-SQL
      CREATE INDEX IF NOT EXISTS idx_audit_logs_action ON oauth_audit_logs(action)
    SQL

    schema.exec <<-SQL
      CREATE INDEX IF NOT EXISTS idx_audit_logs_created ON oauth_audit_logs(created_at DESC)
    SQL
  end

  def down
    schema.exec "DROP INDEX IF EXISTS idx_audit_logs_created"
    schema.exec "DROP INDEX IF EXISTS idx_audit_logs_action"
    schema.exec "DROP INDEX IF EXISTS idx_audit_logs_resource"
    schema.exec "DROP INDEX IF EXISTS idx_audit_logs_actor"
    schema.exec "DROP TABLE IF EXISTS oauth_audit_logs"
  end
end
