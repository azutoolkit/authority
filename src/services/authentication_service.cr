module Authority
  class AuthenticationService
    include SessionHelper

    def self.auth?(req, ip_address : String? = nil)
      new(req, ip_address).call
    end

    def initialize(@req : Sessions::CreateRequest, @ip_address : String? = nil)
    end

    def call
      Log.info { "Starting authentication for user: #{@req.username}" }

      # First check credentials
      unless Authly.owners.authorized?(@req.username, @req.password)
        Log.info { "Authentication failed for user: #{@req.username}" }
        # Record failed login attempt if user exists
        begin
          owner = OwnerRepo.find!(@req.username)
          AdminUserService.record_failed_login(owner.id.to_s)
          Log.info { "Recorded failed login attempt for user: #{@req.username}" }
        rescue
          Log.debug { "User not found when recording failed login: #{@req.username}" }
        end
        return false
      end

      owner = OwnerRepo.find!(@req.username)

      # Check if user account is locked
      if owner.locked?
        Log.info { "Authentication blocked - account locked: #{@req.username}" }
        return false
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
    end
  end
end
