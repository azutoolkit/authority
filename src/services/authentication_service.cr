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
      owner = begin
        OwnerRepo.find!(@req.username)
      rescue
        Log.debug { "User not found: #{@req.username}" }
        # Return generic error to prevent username enumeration
        return AuthResult.new(success: false, error: "Invalid credentials", error_code: "invalid_credentials")
      end

      # Check for auto-unlock if account was previously locked
      if owner.locked? && Security.should_auto_unlock?(owner.locked_at)
        Log.info { "Auto-unlocking account after lockout period: #{@req.username}" }
        AdminUserService.auto_unlock(owner.id.to_s)
        # Refresh the owner record
        owner = OwnerRepo.find!(owner.id.to_s)
      end

      # Check if user account is currently locked
      if owner.locked?
        Log.info { "Authentication blocked - account locked: #{@req.username}" }
        remaining_time = calculate_remaining_lockout(owner.locked_at)
        return AuthResult.new(
          success: false,
          error: "Account is locked. #{remaining_time ? "Try again in #{format_duration(remaining_time)}." : "Please contact support."}",
          error_code: "account_locked",
          retry_after: remaining_time
        )
      end

      # Calculate progressive delay based on failed attempts
      delay = Security.calculate_delay(owner.failed_login_attempts)
      if delay > Time::Span.zero
        Log.info { "Applying progressive delay of #{delay.total_seconds}s for user: #{@req.username}" }
        sleep(delay)
      end

      # Check credentials
      unless Authly.owners.authorized?(@req.username, @req.password)
        Log.info { "Authentication failed for user: #{@req.username}" }

        # Record failed login attempt and check for lockout
        result = AdminUserService.record_failed_login(owner.id.to_s)

        if result.user
          updated_owner = result.user.not_nil!

          # Check if account should be locked
          if Security.should_lock?(updated_owner.failed_login_attempts)
            Log.info { "Locking account after #{updated_owner.failed_login_attempts} failed attempts: #{@req.username}" }
            AdminUserService.auto_lock(
              updated_owner.id.to_s,
              "Automatic lockout after #{updated_owner.failed_login_attempts} failed login attempts"
            )

            return AuthResult.new(
              success: false,
              error: "Account has been locked due to too many failed login attempts. Try again in #{format_duration(Security.lockout_duration)}.",
              error_code: "account_locked",
              retry_after: Security.lockout_duration
            )
          end

          # Return with remaining attempts warning
          remaining = Security.lockout_threshold - updated_owner.failed_login_attempts
          if remaining <= 3 && remaining > 0
            return AuthResult.new(
              success: false,
              error: "Invalid credentials. #{remaining} attempt(s) remaining before account lockout.",
              error_code: "invalid_credentials"
            )
          end
        end

        return AuthResult.new(success: false, error: "Invalid credentials", error_code: "invalid_credentials")
      end

      # Check if MFA is required
      if owner.mfa_enabled
        Log.info { "MFA required for user: #{@req.username}" }
        # Store pending MFA verification in session
        current_session.mfa_pending_user_id = owner.id.to_s
        current_session.mfa_forward_url = @req.forward_url

        return AuthResult.new(
          success: false,
          mfa_required: true,
          user_id: owner.id.to_s,
          error_code: "mfa_required"
        )
      end

      # Record successful login
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
      return nil unless Security.auto_unlock_enabled
      return nil if locked_at.nil?

      elapsed = Time.utc - locked_at.not_nil!
      remaining = Security.lockout_duration - elapsed
      remaining > Time::Span.zero ? remaining : nil
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
