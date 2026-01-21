# Admin Authentication Helper
# Provides authentication and authorization checks for admin endpoints.
# Combines IP allowlist, session auth, and RBAC checks.
module Authority
  module AdminAuthHelper
    macro included
      # Check if request is authorized for admin access
      # Order: IP allowlist -> Session auth -> Admin role/scope
      def admin_authorized? : Bool
        # 1. Check IP allowlist first (if configured)
        if IPAllowlistService.configured?
          client_ip = get_client_ip
          return false unless IPAllowlistService.allowed?(client_ip)
        end

        # 2. Check session authentication
        return false unless authenticated?

        # 3. Check admin role/scope
        user = current_admin_user
        return false unless user
        return false unless RBACService.admin?(user)

        true
      end

      # Get current admin user (returns nil if not admin)
      def current_admin_user : User?
        return nil unless authenticated?

        begin
          user = User.find!(current_session.user_id)
          RBACService.admin?(user) ? user : nil
        rescue
          nil
        end
      end

      # Require admin authorization, returns error response if not authorized
      def require_admin! : Response?
        # Check IP allowlist
        if IPAllowlistService.configured?
          client_ip = get_client_ip
          unless IPAllowlistService.allowed?(client_ip)
            return forbidden_response("Access denied from this IP address")
          end
        end

        # Check authentication
        return redirect_to_signin unless authenticated?

        # Check admin privileges
        user = current_admin_user
        unless user
          return forbidden_response("Admin access required")
        end

        nil # Authorized
      end

      # Return 403 Forbidden response
      def forbidden_response(message : String = "Forbidden") : Response
        status 403
        header "Content-Type", "text/html; charset=UTF-8"
        error message, 403, [message]
      end

      # Get client IP from request
      # Handles X-Forwarded-For header for proxied requests
      def get_client_ip : String
        # Check X-Forwarded-For header first (for reverse proxy setups)
        forwarded = context.request.headers["X-Forwarded-For"]?
        if forwarded
          # Take the first IP (client IP) from the chain
          return forwarded.split(",").first.strip
        end

        # Check X-Real-IP header
        real_ip = context.request.headers["X-Real-IP"]?
        return real_ip.strip if real_ip

        # Fall back to remote address
        remote = context.request.remote_address
        case remote
        when Socket::IPAddress
          remote.address
        else
          "127.0.0.1"
        end
      end
    end
  end
end
