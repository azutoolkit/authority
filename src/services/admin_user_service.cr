# Admin User Management Service
# Provides CRUD operations for users with audit logging support.
# Follows the Class + Result pattern consistent with AdminClientService.
module Authority
  class AdminUserService
    # Result struct for service operations
    struct Result
      getter? success : Bool
      getter user : User?
      getter error : String?
      getter error_code : String?

      def initialize(
        @success : Bool,
        @user : User? = nil,
        @error : String? = nil,
        @error_code : String? = nil
      )
      end
    end

    # List options for filtering
    struct ListOptions
      property page : Int32 = 1
      property per_page : Int32 = 20
      property search : String?
      property status : String?     # "active", "locked", nil for all
      property role : String?       # "user", "admin", nil for all
      property sort_by : String = "created_at"
      property sort_dir : String = "DESC"

      def initialize(
        @page : Int32 = 1,
        @per_page : Int32 = 20,
        @search : String? = nil,
        @status : String? = nil,
        @role : String? = nil,
        @sort_by : String = "created_at",
        @sort_dir : String = "DESC"
      )
      end
    end

    # List all users with pagination and filtering
    def self.list(options : ListOptions = ListOptions.new) : Array(User)
      offset = (options.page - 1) * options.per_page
      results = [] of User

      # Build WHERE conditions
      conditions = [] of String
      params = [] of String | Int32
      param_idx = 1

      # Search filter (username, email, first_name, last_name)
      if search = options.search
        if !search.empty?
          conditions << "(username ILIKE $#{param_idx} OR email ILIKE $#{param_idx} OR first_name ILIKE $#{param_idx} OR last_name ILIKE $#{param_idx})"
          params << "%#{search}%"
          param_idx += 1
        end
      end

      # Status filter
      case options.status
      when "active"
        conditions << "locked_at IS NULL"
      when "locked"
        conditions << "locked_at IS NOT NULL"
      end

      # Role filter
      if role = options.role
        if !role.empty?
          conditions << "role = $#{param_idx}"
          params << role
          param_idx += 1
        end
      end

      where_clause = conditions.empty? ? "" : "WHERE #{conditions.join(" AND ")}"

      # Validate sort column to prevent SQL injection
      valid_sort_columns = ["created_at", "updated_at", "username", "email", "last_login_at"]
      sort_column = valid_sort_columns.includes?(options.sort_by) ? options.sort_by : "created_at"
      sort_direction = options.sort_dir.upcase == "ASC" ? "ASC" : "DESC"

      params << options.per_page
      params << offset

      query = "SELECT id, username, email, first_name, last_name, email_verified, scope, " \
              "encrypted_password, role, locked_at, lock_reason, failed_login_attempts, " \
              "last_login_at, last_login_ip::TEXT, created_at, updated_at " \
              "FROM oauth_owners #{where_clause} " \
              "ORDER BY #{sort_column} #{sort_direction} " \
              "LIMIT $#{param_idx} OFFSET $#{param_idx + 1}"

      AuthorityDB.exec_query do |conn|
        conn.query(query, args: params) do |rs|
          rs.each do
            user = User.new
            user.id = rs.read(UUID)
            user.username = rs.read(String)
            user.email = rs.read(String)
            user.first_name = rs.read(String)
            user.last_name = rs.read(String)
            user.email_verified = rs.read(Bool?) || false
            user.scope = rs.read(String?) || ""
            user.encrypted_password = rs.read(String)
            user.role = rs.read(String?) || "user"
            user.locked_at = rs.read(Time?)
            user.lock_reason = rs.read(String?)
            user.failed_login_attempts = rs.read(Int32?) || 0
            user.last_login_at = rs.read(Time?)
            user.last_login_ip = rs.read(String?)
            user.created_at = rs.read(Time?)
            user.updated_at = rs.read(Time?)
            results << user
          end
        end
      end

      results
    end

    # Count total users with filters
    def self.count(options : ListOptions = ListOptions.new) : Int64
      conditions = [] of String
      params = [] of String
      param_idx = 1

      if search = options.search
        if !search.empty?
          conditions << "(username ILIKE $#{param_idx} OR email ILIKE $#{param_idx} OR first_name ILIKE $#{param_idx} OR last_name ILIKE $#{param_idx})"
          params << "%#{search}%"
          param_idx += 1
        end
      end

      case options.status
      when "active"
        conditions << "locked_at IS NULL"
      when "locked"
        conditions << "locked_at IS NOT NULL"
      end

      if role = options.role
        if !role.empty?
          conditions << "role = $#{param_idx}"
          params << role
        end
      end

      where_clause = conditions.empty? ? "" : "WHERE #{conditions.join(" AND ")}"
      query = "SELECT COUNT(*) FROM oauth_owners #{where_clause}"

      count = 0_i64
      AuthorityDB.exec_query do |conn|
        if params.empty?
          count = conn.scalar(query).as(Int64)
        else
          count = conn.scalar(query, args: params).as(Int64)
        end
      end
      count
    end

    # Get a single user by ID
    def self.get(id : String) : User?
      user = nil

      AuthorityDB.exec_query do |conn|
        conn.query_one?(
          "SELECT id, username, email, first_name, last_name, email_verified, scope, " \
          "encrypted_password, role, locked_at, lock_reason, failed_login_attempts, " \
          "last_login_at, last_login_ip::TEXT, created_at, updated_at " \
          "FROM oauth_owners WHERE id = $1::uuid",
          id
        ) do |rs|
          u = User.new
          u.id = rs.read(UUID)
          u.username = rs.read(String)
          u.email = rs.read(String)
          u.first_name = rs.read(String)
          u.last_name = rs.read(String)
          u.email_verified = rs.read(Bool?) || false
          u.scope = rs.read(String?) || ""
          u.encrypted_password = rs.read(String)
          u.role = rs.read(String?) || "user"
          u.locked_at = rs.read(Time?)
          u.lock_reason = rs.read(String?)
          u.failed_login_attempts = rs.read(Int32?) || 0
          u.last_login_at = rs.read(Time?)
          u.last_login_ip = rs.read(String?)
          u.created_at = rs.read(Time?)
          u.updated_at = rs.read(Time?)
          user = u
        end
      end

      user
    end

    # Create a new user
    def self.create(
      username : String,
      email : String,
      password : String,
      first_name : String,
      last_name : String,
      role : String = "user",
      scope : String = "",
      email_verified : Bool = false,
      actor : User? = nil,
      ip_address : String? = nil
    ) : Result
      # Validate required fields
      return Result.new(success: false, error: "Username is required", error_code: "validation_error") if username.empty?
      return Result.new(success: false, error: "Email is required", error_code: "validation_error") if email.empty?
      return Result.new(success: false, error: "Password is required", error_code: "validation_error") if password.empty?

      # Check for duplicate username
      if exists_by_username?(username)
        return Result.new(success: false, error: "Username already exists", error_code: "duplicate_username")
      end

      # Check for duplicate email
      if exists_by_email?(email)
        return Result.new(success: false, error: "Email already exists", error_code: "duplicate_email")
      end

      # Hash password
      encrypted_password = Crypto::Bcrypt::Password.create(password).to_s
      now = Time.utc
      id = UUID.random.to_s

      AuthorityDB.exec_query do |conn|
        conn.exec("BEGIN")
        begin
          conn.exec(
            "INSERT INTO oauth_owners (id, username, email, first_name, last_name, " \
            "email_verified, scope, encrypted_password, role, failed_login_attempts, " \
            "created_at, updated_at) " \
            "VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, 0, $10, $11)",
            id, username, email, first_name, last_name,
            email_verified, scope, encrypted_password, role, now, now
          )
          conn.exec("COMMIT")
        rescue e
          conn.exec("ROLLBACK")
          raise e
        end
      end

      created_user = get(id)

      # Log audit trail
      if created_user && actor
        AuditService.log(
          actor: actor,
          action: AuditLog::Actions::CREATE,
          resource_type: AuditLog::ResourceTypes::USER,
          resource_id: created_user.id,
          resource_name: created_user.username,
          ip_address: ip_address
        )
      end

      Result.new(success: true, user: created_user)
    rescue e
      Result.new(success: false, error: e.message, error_code: "create_failed")
    end

    # Update user metadata
    def self.update(
      id : String,
      username : String? = nil,
      email : String? = nil,
      first_name : String? = nil,
      last_name : String? = nil,
      role : String? = nil,
      scope : String? = nil,
      email_verified : Bool? = nil,
      actor : User? = nil,
      ip_address : String? = nil
    ) : Result
      user = get(id)
      return Result.new(success: false, error: "User not found", error_code: "not_found") unless user

      # Capture old values for audit diff
      old_values = {
        "username"       => user.username,
        "email"          => user.email,
        "first_name"     => user.first_name,
        "last_name"      => user.last_name,
        "role"           => user.role,
        "scope"          => user.scope,
        "email_verified" => user.email_verified.to_s,
      } of String => String?

      # Check for duplicate username if changing
      if username && username != user.username && exists_by_username?(username)
        return Result.new(success: false, error: "Username already exists", error_code: "duplicate_username")
      end

      # Check for duplicate email if changing
      if email && email != user.email && exists_by_email?(email)
        return Result.new(success: false, error: "Email already exists", error_code: "duplicate_email")
      end

      # Build update query dynamically
      updates = [] of String
      params = [] of String | Time | Bool | Nil
      param_idx = 1

      if username && !username.empty?
        updates << "username = $#{param_idx}"
        params << username
        param_idx += 1
      end

      if email && !email.empty?
        updates << "email = $#{param_idx}"
        params << email
        param_idx += 1
      end

      if first_name
        updates << "first_name = $#{param_idx}"
        params << first_name
        param_idx += 1
      end

      if last_name
        updates << "last_name = $#{param_idx}"
        params << last_name
        param_idx += 1
      end

      if role
        updates << "role = $#{param_idx}"
        params << role
        param_idx += 1
      end

      if scope
        updates << "scope = $#{param_idx}"
        params << scope
        param_idx += 1
      end

      unless email_verified.nil?
        updates << "email_verified = $#{param_idx}"
        params << email_verified
        param_idx += 1
      end

      updates << "updated_at = $#{param_idx}"
      params << Time.utc
      param_idx += 1

      params << id

      return Result.new(success: true, user: user) if updates.size == 1 # Only updated_at

      AuthorityDB.exec_query do |conn|
        conn.exec("BEGIN")
        begin
          conn.exec(
            "UPDATE oauth_owners SET #{updates.join(", ")} WHERE id = $#{param_idx}::uuid",
            args: params
          )
          conn.exec("COMMIT")
        rescue e
          conn.exec("ROLLBACK")
          raise e
        end
      end

      updated_user = get(id)

      # Log audit trail with changes
      if updated_user && actor
        new_values = {
          "username"       => updated_user.username,
          "email"          => updated_user.email,
          "first_name"     => updated_user.first_name,
          "last_name"      => updated_user.last_name,
          "role"           => updated_user.role,
          "scope"          => updated_user.scope,
          "email_verified" => updated_user.email_verified.to_s,
        } of String => String?

        changes = AuditService.diff(old_values, new_values)

        AuditService.log(
          actor: actor,
          action: AuditLog::Actions::UPDATE,
          resource_type: AuditLog::ResourceTypes::USER,
          resource_id: updated_user.id,
          resource_name: updated_user.username,
          changes: changes,
          ip_address: ip_address
        )
      end

      Result.new(success: true, user: updated_user)
    rescue e
      Result.new(success: false, error: e.message, error_code: "update_failed")
    end

    # Lock a user account
    def self.lock(
      id : String,
      reason : String,
      actor : User,
      ip_address : String? = nil
    ) : Result
      user = get(id)
      return Result.new(success: false, error: "User not found", error_code: "not_found") unless user

      # Cannot lock yourself
      if actor.id.to_s == id
        return Result.new(success: false, error: "Cannot lock your own account", error_code: "self_lock_forbidden")
      end

      # Cannot lock another admin unless super admin
      if RBACService.admin?(user) && !RBACService.has_scope?(actor, "authority:super_admin")
        return Result.new(success: false, error: "Cannot lock admin users", error_code: "admin_lock_forbidden")
      end

      now = Time.utc

      AuthorityDB.exec_query do |conn|
        conn.exec("BEGIN")
        begin
          # Lock the user
          conn.exec(
            "UPDATE oauth_owners SET locked_at = $1, lock_reason = $2, updated_at = $3 WHERE id = $4::uuid",
            now, reason, now, id
          )

          # Note: Sessions are managed in-memory/cookies, not database
          # The locked user will be blocked on next request when locked_at is checked

          conn.exec("COMMIT")
        rescue e
          conn.exec("ROLLBACK")
          raise e
        end
      end

      locked_user = get(id)

      # Log audit trail
      if locked_user
        AuditService.log(
          actor: actor,
          action: AuditLog::Actions::LOCK,
          resource_type: AuditLog::ResourceTypes::USER,
          resource_id: locked_user.id,
          resource_name: locked_user.username,
          changes: {"reason" => [nil.as(String?), reason.as(String?)]},
          ip_address: ip_address
        )
      end

      Result.new(success: true, user: locked_user)
    rescue e
      Result.new(success: false, error: e.message, error_code: "lock_failed")
    end

    # Unlock a user account
    def self.unlock(
      id : String,
      actor : User,
      ip_address : String? = nil
    ) : Result
      user = get(id)
      return Result.new(success: false, error: "User not found", error_code: "not_found") unless user

      unless user.locked?
        return Result.new(success: false, error: "User is not locked", error_code: "not_locked")
      end

      now = Time.utc

      AuthorityDB.exec_query do |conn|
        conn.exec("BEGIN")
        begin
          conn.exec(
            "UPDATE oauth_owners SET locked_at = NULL, lock_reason = NULL, " \
            "failed_login_attempts = 0, updated_at = $1 WHERE id = $2::uuid",
            now, id
          )
          conn.exec("COMMIT")
        rescue e
          conn.exec("ROLLBACK")
          raise e
        end
      end

      unlocked_user = get(id)

      # Log audit trail
      if unlocked_user
        AuditService.log(
          actor: actor,
          action: AuditLog::Actions::UNLOCK,
          resource_type: AuditLog::ResourceTypes::USER,
          resource_id: unlocked_user.id,
          resource_name: unlocked_user.username,
          ip_address: ip_address
        )
      end

      Result.new(success: true, user: unlocked_user)
    rescue e
      Result.new(success: false, error: e.message, error_code: "unlock_failed")
    end

    # Set a temporary password
    def self.set_temp_password(
      id : String,
      password : String,
      actor : User,
      ip_address : String? = nil
    ) : Result
      user = get(id)
      return Result.new(success: false, error: "User not found", error_code: "not_found") unless user

      return Result.new(success: false, error: "Password is required", error_code: "validation_error") if password.empty?

      encrypted_password = Crypto::Bcrypt::Password.create(password).to_s
      now = Time.utc

      AuthorityDB.exec_query do |conn|
        conn.exec("BEGIN")
        begin
          conn.exec(
            "UPDATE oauth_owners SET encrypted_password = $1, updated_at = $2 WHERE id = $3::uuid",
            encrypted_password, now, id
          )
          conn.exec("COMMIT")
        rescue e
          conn.exec("ROLLBACK")
          raise e
        end
      end

      updated_user = get(id)

      # Log audit trail (do not log password value!)
      if updated_user
        AuditService.log(
          actor: actor,
          action: AuditLog::Actions::RESET_PASS,
          resource_type: AuditLog::ResourceTypes::USER,
          resource_id: updated_user.id,
          resource_name: updated_user.username,
          ip_address: ip_address
        )
      end

      Result.new(success: true, user: updated_user)
    rescue e
      Result.new(success: false, error: e.message, error_code: "password_reset_failed")
    end

    # Delete a user with cascade
    def self.delete(
      id : String,
      actor : User,
      ip_address : String? = nil
    ) : Result
      user = get(id)
      return Result.new(success: false, error: "User not found", error_code: "not_found") unless user

      # Cannot delete yourself
      if actor.id.to_s == id
        return Result.new(success: false, error: "Cannot delete your own account", error_code: "self_delete_forbidden")
      end

      # Cannot delete another admin unless super admin
      if RBACService.admin?(user) && !RBACService.has_scope?(actor, "authority:super_admin")
        return Result.new(success: false, error: "Cannot delete admin users", error_code: "admin_delete_forbidden")
      end

      # Capture user info for audit before deletion
      user_username = user.username
      user_uuid = user.id

      AuthorityDB.exec_query do |conn|
        conn.exec("BEGIN")
        begin
          # Delete associated tokens (user_id is TEXT type)
          conn.exec("DELETE FROM oauth_opaque_tokens WHERE user_id = $1", id)

          # Delete associated consents (user_id is TEXT type)
          conn.exec("DELETE FROM oauth_consents WHERE user_id = $1", id)

          # Note: Sessions are managed in-memory/cookies, not database

          # Delete user
          conn.exec("DELETE FROM oauth_owners WHERE id = $1::uuid", id)

          conn.exec("COMMIT")
        rescue e
          conn.exec("ROLLBACK")
          raise e
        end
      end

      # Log audit trail
      AuditService.log(
        actor: actor,
        action: AuditLog::Actions::DELETE,
        resource_type: AuditLog::ResourceTypes::USER,
        resource_id: user_uuid,
        resource_name: user_username,
        ip_address: ip_address
      )

      Result.new(success: true)
    rescue e
      Result.new(success: false, error: e.message, error_code: "delete_failed")
    end

    # Record a successful login
    def self.record_login(id : String, ip_address : String) : Result
      now = Time.utc

      AuthorityDB.exec_query do |conn|
        conn.exec(
          "UPDATE oauth_owners SET last_login_at = $1, last_login_ip = $2, " \
          "failed_login_attempts = 0, updated_at = $3 WHERE id = $4::uuid",
          now, ip_address, now, id
        )
      end

      user = get(id)
      Result.new(success: true, user: user)
    rescue e
      Result.new(success: false, error: e.message, error_code: "record_login_failed")
    end

    # Record a failed login attempt
    def self.record_failed_login(id : String) : Result
      AuthorityDB.exec_query do |conn|
        conn.exec(
          "UPDATE oauth_owners SET failed_login_attempts = failed_login_attempts + 1, " \
          "updated_at = $1 WHERE id = $2::uuid",
          Time.utc, id
        )
      end

      user = get(id)
      Result.new(success: true, user: user)
    rescue e
      Result.new(success: false, error: e.message, error_code: "record_failed_login_failed")
    end

    # Check if username exists
    private def self.exists_by_username?(username : String) : Bool
      count = 0_i64
      AuthorityDB.exec_query do |conn|
        count = conn.scalar("SELECT COUNT(*) FROM oauth_owners WHERE username = $1", username).as(Int64)
      end
      count > 0
    end

    # Check if email exists
    private def self.exists_by_email?(email : String) : Bool
      count = 0_i64
      AuthorityDB.exec_query do |conn|
        count = conn.scalar("SELECT COUNT(*) FROM oauth_owners WHERE email = $1", email).as(Int64)
      end
      count > 0
    end
  end
end
