module Authority
  module OwnerRepo
    def self.authenticate?(username : String, password : String)
      user = find!(username)
      return false unless user
      user.verify?(password)
    rescue
      false
    end

    def self.id_token(user_id : String) : Hash(String, Int64 | String)
      user = find_by_id(user_id)
      user.try(&.id_token) || {} of String => Int64 | String
    end

    def self.find!(username_or_email : String) : User
      user = find_by_username_or_email(username_or_email)
      raise "User not found" unless user
      user
    end

    def self.find_by_username_or_email(username_or_email : String) : User?
      # Use raw SQL to bypass ORM UUID issues
      sql = <<-SQL
        SELECT id::text, username, email, first_name, last_name, encrypted_password,
               role, scope, email_verified, locked_at, lock_reason,
               failed_login_attempts, last_login_at, last_login_ip::text,
               created_at, updated_at
        FROM oauth_owners
        WHERE username = $1 OR email = $1
        LIMIT 1
      SQL

      AuthorityDB.exec_query do |conn|
        conn.query_one?(sql, username_or_email) do |rs|
          build_user_from_rs(rs)
        end
      end
    end

    def self.find_by_id(user_id : String) : User?
      sql = <<-SQL
        SELECT id::text, username, email, first_name, last_name, encrypted_password,
               role, scope, email_verified, locked_at, lock_reason,
               failed_login_attempts, last_login_at, last_login_ip::text,
               created_at, updated_at
        FROM oauth_owners
        WHERE id = $1::uuid
        LIMIT 1
      SQL

      AuthorityDB.exec_query do |conn|
        conn.query_one?(sql, user_id) do |rs|
          build_user_from_rs(rs)
        end
      end
    end

    private def self.build_user_from_rs(rs) : User
      user = User.new
      user.id = rs.read(String)
      user.username = rs.read(String)
      user.email = rs.read(String)
      user.first_name = rs.read(String)
      user.last_name = rs.read(String)
      user.encrypted_password = rs.read(String)
      user.role = rs.read(String)
      user.scope = rs.read(String)
      user.email_verified = rs.read(Bool)
      user.locked_at = rs.read(Time?)
      user.lock_reason = rs.read(String?)
      user.failed_login_attempts = rs.read(Int32)
      user.last_login_at = rs.read(Time?)
      user.last_login_ip = rs.read(String?)
      user.created_at = rs.read(Time?)
      user.updated_at = rs.read(Time?)
      user
    end

    def self.create!(req : Owner::NewRequest)
      encrypted_password = Crypto::Bcrypt::Password.create(req.password).to_s

      sql = <<-SQL
        INSERT INTO oauth_owners (
          id, username, email, first_name, last_name, encrypted_password,
          scope, email_verified, created_at, updated_at
        )
        VALUES (
          uuid_generate_v4(), $1, $2, $3, $4, $5, '', false, NOW(), NOW()
        )
        RETURNING id::text
      SQL

      AuthorityDB.exec_query do |conn|
        user_id = conn.query_one(sql, req.username, req.email, req.first_name, req.last_name, encrypted_password, as: String)
        find_by_id(user_id).not_nil!
      end
    end
  end
end
