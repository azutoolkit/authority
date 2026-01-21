module Authority
  class AuthenticationService
    include SessionHelper

    def self.auth?(req, ip_address : String? = nil)
      new(req, ip_address).call
    end

    def initialize(@req : Sessions::CreateRequest, @ip_address : String? = nil)
    end

    def call
      # First check credentials
      unless Authly.owners.authorized?(@req.username, @req.password)
        # Record failed login attempt if user exists
        begin
          owner = OwnerRepo.find!(@req.username)
          AdminUserService.record_failed_login(owner.id.to_s)
        rescue
          # User doesn't exist - ignore
        end
        return false
      end

      owner = OwnerRepo.find!(@req.username)

      # Check if user account is locked
      if owner.locked?
        return false
      end

      # Record successful login
      if ip = @ip_address
        AdminUserService.record_login(owner.id.to_s, ip)
      end

      current_session.user_id = owner.id.to_s
      current_session.email = owner.email
      current_session.authenticated = true
    end
  end
end
