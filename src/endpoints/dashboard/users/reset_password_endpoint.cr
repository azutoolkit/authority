# Endpoint for Admin User Reset Password
# POST /dashboard/users/:id/reset-password - Set a temporary password
module Authority::Dashboard::Users
  class ResetPasswordEndpoint
    include SessionHelper
    include SecurityHeadersHelper
    include AdminAuthHelper
    include Endpoint(ResetPasswordRequest, Response)

    post "/dashboard/users/:id/reset-password"

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

      # Set temporary password
      result = AdminUserService.set_temp_password(
        id: reset_password_request.id,
        password: reset_password_request.password,
        actor: admin_user
      )

      # Redirect back to user details
      redirect to: "/dashboard/users/#{reset_password_request.id}", status: 302
    end
  end
end
