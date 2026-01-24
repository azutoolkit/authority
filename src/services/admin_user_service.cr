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

      query = User.query

      # Role filter (can be done at DB level)
      if role = options.role
        query = query.where(role: role) unless role.empty?
      end

      # Validate sort column to prevent SQL injection
      valid_sort_columns = ["created_at", "updated_at", "username", "email", "last_login_at"]
      sort_column = valid_sort_columns.includes?(options.sort_by) ? options.sort_by : "created_at"
      sort_direction = options.sort_dir.upcase == "ASC" ? :asc : :desc

      # Apply ordering based on validated column
      case sort_column
      when "created_at"
        query = query.order(created_at: sort_direction)
      when "updated_at"
        query = query.order(updated_at: sort_direction)
      when "username"
        query = query.order(username: sort_direction)
      when "email"
        query = query.order(email: sort_direction)
      when "last_login_at"
        query = query.order(last_login_at: sort_direction)
      end

      # Fetch all matching users, then apply in-memory filters
      results = query.all

      # Apply search filter in memory (block DSL doesn't work outside model context)
      if search = options.search
        if !search.empty?
          pattern = search.downcase
          results = results.select do |user|
            user.username.downcase.includes?(pattern) ||
              user.email.downcase.includes?(pattern) ||
              user.first_name.downcase.includes?(pattern) ||
              user.last_name.downcase.includes?(pattern)
          end
        end
      end

      # Apply status filter in memory
      case options.status
      when "active"
        results = results.select { |user| user.locked_at.nil? }
      when "locked"
        results = results.select { |user| !user.locked_at.nil? }
      end

      # Apply pagination in memory
      results.skip(offset).first(options.per_page)
    end

    # Count total users with filters
    def self.count(options : ListOptions = ListOptions.new) : Int64
      # Use list with a large limit and count results for filtered queries
      # This ensures consistent filtering behavior between list and count
      list(ListOptions.new(
        page: 1,
        per_page: Int32::MAX,
        search: options.search,
        status: options.status,
        role: options.role
      )).size.to_i64
    end

    # Get a single user by ID
    def self.get(id : String) : User?
      User.find_by(id: id)
    rescue
      nil
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
      ip_address : String? = nil,
      skip_password_validation : Bool = false
    ) : Result
      # Validate required fields
      return Result.new(success: false, error: "Username is required", error_code: "validation_error") if username.empty?
      return Result.new(success: false, error: "Email is required", error_code: "validation_error") if email.empty?
      return Result.new(success: false, error: "Password is required", error_code: "validation_error") if password.empty?

      # Validate password policy
      unless skip_password_validation
        validation = PasswordPolicyService.validate(password)
        unless validation.valid?
          return Result.new(success: false, error: validation.errors.first, error_code: "password_policy_error")
        end
      end

      # Check for duplicate username
      if exists_by_username?(username)
        return Result.new(success: false, error: "Username already exists", error_code: "duplicate_username")
      end

      # Check for duplicate email
      if exists_by_email?(email)
        return Result.new(success: false, error: "Email already exists", error_code: "duplicate_email")
      end

      now = Time.utc

      user = User.new
      user.username = username
      user.email = email
      user.first_name = first_name
      user.last_name = last_name
      user.email_verified = email_verified
      user.scope = scope
      user.password = password
      user.role = role
      user.failed_login_attempts = 0
      user.password_changed_at = now
      user.created_at = now
      user.updated_at = now
      user.save!

      created_user = user

      # Log audit trail
      if created_user && actor
        AuditService.log(
          actor: actor,
          action: AuditLog::Actions::CREATE,
          resource_type: AuditLog::ResourceTypes::USER,
          resource_id: created_user.id.to_s,
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

      # Update fields if provided
      has_changes = false

      if username && !username.empty?
        user.username = username
        has_changes = true
      end

      if email && !email.empty?
        user.email = email
        has_changes = true
      end

      if first_name
        user.first_name = first_name
        has_changes = true
      end

      if last_name
        user.last_name = last_name
        has_changes = true
      end

      if role
        user.role = role
        has_changes = true
      end

      if scope
        user.scope = scope
        has_changes = true
      end

      unless email_verified.nil?
        user.email_verified = email_verified
        has_changes = true
      end

      return Result.new(success: true, user: user) unless has_changes

      user.updated_at = Time.utc
      user.update!

      updated_user = user

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
          resource_id: updated_user.id.to_s,
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

      # Lock the user
      user.locked_at = now
      user.lock_reason = reason
      user.updated_at = now
      user.update!

      # Note: Sessions are managed in-memory/cookies, not database
      # The locked user will be blocked on next request when locked_at is checked

      locked_user = user

      # Log audit trail
      if locked_user
        AuditService.log(
          actor: actor,
          action: AuditLog::Actions::LOCK,
          resource_type: AuditLog::ResourceTypes::USER,
          resource_id: locked_user.id.to_s,
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

      user.locked_at = nil
      user.lock_reason = nil
      user.failed_login_attempts = 0
      user.updated_at = now
      user.update!

      unlocked_user = user

      # Log audit trail
      if unlocked_user
        AuditService.log(
          actor: actor,
          action: AuditLog::Actions::UNLOCK,
          resource_type: AuditLog::ResourceTypes::USER,
          resource_id: unlocked_user.id.to_s,
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
      ip_address : String? = nil,
      skip_password_validation : Bool = false,
      skip_password_history : Bool = false
    ) : Result
      user = get(id)
      return Result.new(success: false, error: "User not found", error_code: "not_found") unless user

      return Result.new(success: false, error: "Password is required", error_code: "validation_error") if password.empty?

      # Validate password policy
      unless skip_password_validation
        validation = PasswordPolicyService.validate(password, user)
        unless validation.valid?
          return Result.new(success: false, error: validation.errors.first, error_code: "password_policy_error")
        end
      end

      now = Time.utc

      # Add old password to history before changing
      unless skip_password_history
        user.password_history = PasswordPolicyService.add_to_history(user, user.encrypted_password)
      end

      user.password = password
      user.password_changed_at = now
      user.updated_at = now
      user.update!

      updated_user = user

      # Log audit trail (do not log password value!)
      if updated_user
        AuditService.log(
          actor: actor,
          action: AuditLog::Actions::RESET_PASS,
          resource_type: AuditLog::ResourceTypes::USER,
          resource_id: updated_user.id.to_s,
          resource_name: updated_user.username,
          ip_address: ip_address
        )
      end

      # Send notification email
      spawn do
        EmailService.send_password_changed(
          updated_user.email,
          updated_user.first_name.empty? ? updated_user.username : updated_user.first_name
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
      user_uuid = user.id.to_s

      # Delete associated tokens
      OpaqueToken.where(user_id: id).delete_all

      # Delete associated consents
      Consent.where(user_id: id).delete_all

      # Note: Sessions are managed in-memory/cookies, not database

      # Delete user
      user.delete!

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
      user = get(id)
      return Result.new(success: false, error: "User not found", error_code: "not_found") unless user

      now = Time.utc
      user.last_login_at = now
      user.last_login_ip = ip_address
      user.failed_login_attempts = 0
      user.updated_at = now
      user.update!

      Result.new(success: true, user: user)
    rescue e
      Result.new(success: false, error: e.message, error_code: "record_login_failed")
    end

    # Record a failed login attempt
    def self.record_failed_login(id : String) : Result
      user = get(id)
      return Result.new(success: false, error: "User not found", error_code: "not_found") unless user

      user.failed_login_attempts = user.failed_login_attempts + 1
      user.updated_at = Time.utc
      user.update!

      Result.new(success: true, user: user)
    rescue e
      Result.new(success: false, error: e.message, error_code: "record_failed_login_failed")
    end

    # Automatically lock an account (system-initiated, no actor required)
    def self.auto_lock(id : String, reason : String) : Result
      user = get(id)
      return Result.new(success: false, error: "User not found", error_code: "not_found") unless user

      # Don't lock if already locked
      return Result.new(success: true, user: user) if user.locked?

      now = Time.utc

      user.locked_at = now
      user.lock_reason = reason
      user.updated_at = now
      user.update!

      Log.info { "Account auto-locked: #{user.username} - Reason: #{reason}" }

      # Log audit trail as system action
      AuditService.log_system(
        action: AuditLog::Actions::LOCK,
        resource_type: AuditLog::ResourceTypes::USER,
        resource_id: user.id.to_s,
        resource_name: user.username,
        changes: {
          "reason"     => [nil.as(String?), reason.as(String?)],
          "auto_lock"  => [nil.as(String?), "true".as(String?)],
          "threshold"  => [nil.as(String?), Security.lockout_threshold.to_s.as(String?)],
          "failed_attempts" => [nil.as(String?), user.failed_login_attempts.to_s.as(String?)]
        }
      )

      # Send lockout notification email
      unlock_at = Security.auto_unlock_enabled ? now + Security.lockout_duration : nil
      spawn do
        EmailService.send_account_locked(
          user.email,
          user.first_name.empty? ? user.username : user.first_name,
          reason,
          unlock_at
        )
      end

      Result.new(success: true, user: user)
    rescue e
      Result.new(success: false, error: e.message, error_code: "auto_lock_failed")
    end

    # Automatically unlock an account after lockout duration expires
    def self.auto_unlock(id : String) : Result
      user = get(id)
      return Result.new(success: false, error: "User not found", error_code: "not_found") unless user

      # Don't unlock if not locked
      return Result.new(success: true, user: user) unless user.locked?

      now = Time.utc

      user.locked_at = nil
      user.lock_reason = nil
      user.failed_login_attempts = 0
      user.updated_at = now
      user.update!

      Log.info { "Account auto-unlocked after lockout period: #{user.username}" }

      # Log audit trail as system action
      AuditService.log_system(
        action: AuditLog::Actions::UNLOCK,
        resource_type: AuditLog::ResourceTypes::USER,
        resource_id: user.id.to_s,
        resource_name: user.username,
        changes: {
          "auto_unlock" => [nil.as(String?), "true".as(String?)],
          "lockout_duration_minutes" => [nil.as(String?), Security.lockout_duration.total_minutes.to_i.to_s.as(String?)]
        }
      )

      Result.new(success: true, user: user)
    rescue e
      Result.new(success: false, error: e.message, error_code: "auto_unlock_failed")
    end

    # Reset failed login attempts (e.g., after manual intervention)
    def self.reset_failed_attempts(id : String, actor : User? = nil, ip_address : String? = nil) : Result
      user = get(id)
      return Result.new(success: false, error: "User not found", error_code: "not_found") unless user

      old_attempts = user.failed_login_attempts

      user.failed_login_attempts = 0
      user.updated_at = Time.utc
      user.update!

      # Log audit trail if actor provided
      if actor
        AuditService.log(
          actor: actor,
          action: "reset_failed_attempts",
          resource_type: AuditLog::ResourceTypes::USER,
          resource_id: user.id.to_s,
          resource_name: user.username,
          changes: {"failed_login_attempts" => [old_attempts.to_s.as(String?), "0".as(String?)]},
          ip_address: ip_address
        )
      end

      Result.new(success: true, user: user)
    rescue e
      Result.new(success: false, error: e.message, error_code: "reset_failed_attempts_failed")
    end

    # Bulk result struct
    struct BulkResult
      getter? success : Bool
      getter succeeded : Int32
      getter failed : Int32
      getter errors : Array(String)

      def initialize(
        @success : Bool,
        @succeeded : Int32 = 0,
        @failed : Int32 = 0,
        @errors : Array(String) = [] of String
      )
      end
    end

    # Bulk lock multiple users
    def self.bulk_lock(
      ids : Array(String),
      reason : String,
      actor : User,
      ip_address : String? = nil
    ) : BulkResult
      succeeded = 0
      failed = 0
      errors = [] of String

      ids.each do |id|
        result = lock(id, reason, actor, ip_address)
        if result.success?
          succeeded += 1
        else
          failed += 1
          errors << "User #{id}: #{result.error}"
        end
      end

      BulkResult.new(
        success: failed == 0,
        succeeded: succeeded,
        failed: failed,
        errors: errors
      )
    end

    # Bulk unlock multiple users
    def self.bulk_unlock(
      ids : Array(String),
      actor : User,
      ip_address : String? = nil
    ) : BulkResult
      succeeded = 0
      failed = 0
      errors = [] of String

      ids.each do |id|
        result = unlock(id, actor, ip_address)
        if result.success?
          succeeded += 1
        else
          failed += 1
          errors << "User #{id}: #{result.error}"
        end
      end

      BulkResult.new(
        success: failed == 0,
        succeeded: succeeded,
        failed: failed,
        errors: errors
      )
    end

    # Bulk delete multiple users
    def self.bulk_delete(
      ids : Array(String),
      actor : User,
      ip_address : String? = nil
    ) : BulkResult
      succeeded = 0
      failed = 0
      errors = [] of String

      ids.each do |id|
        result = delete(id, actor, ip_address)
        if result.success?
          succeeded += 1
        else
          failed += 1
          errors << "User #{id}: #{result.error}"
        end
      end

      BulkResult.new(
        success: failed == 0,
        succeeded: succeeded,
        failed: failed,
        errors: errors
      )
    end

    # Check if username exists
    private def self.exists_by_username?(username : String) : Bool
      User.exists?(username: username)
    end

    # Check if email exists
    private def self.exists_by_email?(email : String) : Bool
      User.exists?(email: email)
    end
  end
end
