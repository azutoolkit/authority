# Create table for Pushed Authorization Requests (PAR) per RFC 9126
class CreateParRequests < CQL::Migration(1768940400_i64)
  def up
    schema.exec <<-SQL
      CREATE TABLE IF NOT EXISTS oauth_par_requests (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        request_uri TEXT NOT NULL UNIQUE,
        client_id TEXT NOT NULL,
        redirect_uri TEXT NOT NULL,
        response_type TEXT NOT NULL,
        scope TEXT,
        state TEXT,
        code_challenge TEXT,
        code_challenge_method TEXT,
        nonce TEXT,
        used BOOLEAN NOT NULL DEFAULT FALSE,
        expires_at TIMESTAMP NOT NULL,
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    SQL

    schema.exec <<-SQL
      CREATE INDEX IF NOT EXISTS idx_par_requests_uri ON oauth_par_requests(request_uri)
    SQL
    schema.exec <<-SQL
      CREATE INDEX IF NOT EXISTS idx_par_requests_expires ON oauth_par_requests(expires_at)
    SQL
  end

  def down
    schema.exec %(DROP TABLE IF EXISTS oauth_par_requests)
  end
end
