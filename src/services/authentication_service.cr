module Authority
  class AuthenticationService
    include SessionHelper

    # Result struct for authentication with detailed status
    struct AuthResult
      getter? success : Bool
      getter? mfa_required : Bool
      getter user_id : String?
      getter error : String?
      getter error_code : String?
      getter retry_after : Time::Span?

      def initialize(
        @success : Bool,
        @mfa_required : Bool = false,
        @user_id : String? = nil,
        @error : String? = nil,
        @error_code : String? = nil,
        @retry_after : Time::Span? = nil
      )
      end
    end

    def self.auth?(req, ip_address : String? = nil)
      new(req, ip_address).call
    end

    # New method that returns detailed result
    def self.authenticate(req, ip_address : String? = nil) : AuthResult
      new(req, ip_address).authenticate
    end

    def initialize(@req : Sessions::CreateRequest, @ip_address : String? = nil)
    end

    def call
      result = authenticate
      result.success?
    end

    def authenticate : AuthResult
      Log.info { "Starting authentication for user: #{@req.username}" }

      # Try to find the user first for account status checks
      owner = find_user_or_fail
      return owner if owner.is_a?(AuthResult)

      # Handle auto-unlock and check current lock status
      owner = handle_auto_unlock(owner)
      if lockout_result = check_account_lockout(owner)
        return lockout_result
      end

      # Apply progressive delay based on failed attempts
      apply_progressive_delay(owner)

      # Validate credentials
      unless Authly.owners.authorized?(@req.username, @req.password)
        return handle_failed_login(owner)
      end

      # Check if MFA is required
      if mfa_result = check_mfa_required(owner)
        return mfa_result
      end

      # Complete successful authentication
      complete_successful_login(owner)
    end

    # Find user or return error result
    private def find_user_or_fail : User | AuthResult
      OwnerRepo.find!(@req.username)
    rescue
      Log.debug { "User not found: #{@req.username}" }
      AuthResult.new(success: false, error: "Invalid credentials", error_code: "invalid_credentials")
    end

    # Handle auto-unlock for previously locked accounts
    private def handle_auto_unlock(owner : User) : User
      if owner.locked? && Security.should_auto_unlock?(owner.locked_at)
        Log.info { "Auto-unlocking account after lockout period: #{@req.username}" }
        AdminUserService.auto_unlock(owner.id.to_s)
        return OwnerRepo.find!(owner.id.to_s)
      end
      owner
    end

    # Check if account is locked and return error if so
    private def check_account_lockout(owner : User) : AuthResult?
      return nil unless owner.locked?

      Log.info { "Authentication blocked - account locked: #{@req.username}" }
      remaining_time = calculate_remaining_lockout(owner.locked_at)
      AuthResult.new(
        success: false,
        error: "Account is locked. #{remaining_time ? "Try again in #{format_duration(remaining_time)}." : "Please contact support."}",
        error_code: "account_locked",
        retry_after: remaining_time
      )
    end

    # Apply progressive delay based on failed login attempts
    private def apply_progressive_delay(owner : User) : Nil
      delay = Security.calculate_delay(owner.failed_login_attempts)
      if delay > Time::Span.zero
        Log.info { "Applying progressive delay of #{delay.total_seconds}s for user: #{@req.username}" }
        sleep(delay)
      end
    end

    # Handle failed login attempt, including lockout logic
    private def handle_failed_login(owner : User) : AuthResult
      Log.info { "Authentication failed for user: #{@req.username}" }
      result = AdminUserService.record_failed_login(owner.id.to_s)

      if updated_owner = result.user
        if lockout_result = check_and_apply_lockout(updated_owner)
          return lockout_result
        end
        if warning_result = build_remaining_attempts_warning(updated_owner)
          return warning_result
        end
      end

      AuthResult.new(success: false, error: "Invalid credentials", error_code: "invalid_credentials")
    end

    # Check if account should be locked and apply lockout
    private def check_and_apply_lockout(owner : User) : AuthResult?
      return nil unless Security.should_lock?(owner.failed_login_attempts)

      Log.info { "Locking account after #{owner.failed_login_attempts} failed attempts: #{@req.username}" }
      AdminUserService.auto_lock(
        owner.id.to_s,
        "Automatic lockout after #{owner.failed_login_attempts} failed login attempts"
      )

      AuthResult.new(
        success: false,
        error: "Account has been locked due to too many failed login attempts. Try again in #{format_duration(Security.lockout_duration)}.",
        error_code: "account_locked",
        retry_after: Security.lockout_duration
      )
    end

    # Build warning message for remaining login attempts
    private def build_remaining_attempts_warning(owner : User) : AuthResult?
      remaining = Security.lockout_threshold - owner.failed_login_attempts
      return nil unless remaining <= 3 && remaining > 0

      AuthResult.new(
        success: false,
        error: "Invalid credentials. #{remaining} attempt(s) remaining before account lockout.",
        error_code: "invalid_credentials"
      )
    end

    # Check if MFA is required and return MFA pending result
    private def check_mfa_required(owner : User) : AuthResult?
      return nil unless owner.mfa_enabled

      Log.info { "MFA required for user: #{@req.username}" }
      current_session.mfa_pending_user_id = owner.id.to_s
      current_session.mfa_forward_url = @req.forward_url

      AuthResult.new(
        success: false,
        mfa_required: true,
        user_id: owner.id.to_s,
        error_code: "mfa_required"
      )
    end

    # Complete successful authentication
    private def complete_successful_login(owner : User) : AuthResult
      if ip = @ip_address
        AdminUserService.record_login(owner.id.to_s, ip)
        Log.info { "Authentication successful for user: #{@req.username} from IP: #{ip}" }
      else
        Log.info { "Authentication successful for user: #{@req.username}" }
      end

      current_session.user_id = owner.id.to_s
      current_session.email = owner.email
      current_session.authenticated = true

      AuthResult.new(success: true)
    end

    private def calculate_remaining_lockout(locked_at : Time?) : Time::Span?
      return nil unless Security.auto_unlock_enabled?

      if lock_time = locked_at
        elapsed = Time.utc - lock_time
        remaining = Security.lockout_duration - elapsed
        remaining > Time::Span.zero ? remaining : nil
      end
    end

    private def format_duration(span : Time::Span) : String
      total_seconds = span.total_seconds.to_i
      if total_seconds >= 3600
        hours = total_seconds // 3600
        minutes = (total_seconds % 3600) // 60
        "#{hours} hour#{"s" if hours > 1}#{" #{minutes} minute#{"s" if minutes > 1}" if minutes > 0}"
      elsif total_seconds >= 60
        minutes = total_seconds // 60
        "#{minutes} minute#{"s" if minutes > 1}"
      else
        "#{total_seconds} second#{"s" if total_seconds > 1}"
      end
    end
  end
end
