# Endpoint for Admin User Unlock
# POST /dashboard/users/:id/unlock - Unlock a user account
module Authority::Dashboard::Users
  class UnlockEndpoint
    include SessionHelper
    include SecurityHeadersHelper
    include AdminAuthHelper
    include Endpoint(UnlockRequest, Response)

    post "/dashboard/users/:id/unlock"

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

      # Unlock the user
      result = AdminUserService.unlock(
        id: unlock_request.id,
        actor: admin_user
      )

      # Redirect back to user details
      redirect to: "/dashboard/users/#{unlock_request.id}", status: 302
    end
  end
end
