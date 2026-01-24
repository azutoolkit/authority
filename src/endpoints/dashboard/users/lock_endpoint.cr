# Endpoint for Admin User Lock
# POST /dashboard/users/:id/lock - Lock a user account
module Authority::Dashboard::Users
  class LockEndpoint
    include SessionHelper
    include SecurityHeadersHelper
    include AdminAuthHelper
    include Endpoint(LockRequest, Response)

    post "/dashboard/users/:id/lock"

    def call : Response
      set_security_headers!
      header "Content-Type", "text/html; charset=UTF-8"
      header "Cache-Control", "no-store"
      header "Pragma", "no-cache"

      # Check admin authorization
      if auth_error = require_admin!
        return auth_error
      end

      admin_user = current_admin_user
      return forbidden_response("Admin access required") unless admin_user

      reason = lock_request.reason.empty? ? "Locked by admin" : lock_request.reason

      # Lock the user
      AdminUserService.lock(
        id: lock_request.id,
        reason: reason,
        actor: admin_user
      )

      # Redirect back to user details
      redirect to: "/dashboard/users/#{lock_request.id}", status: 302
    end
  end
end
