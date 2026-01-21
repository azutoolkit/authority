# Endpoint for Admin User Delete
# POST /dashboard/users/:id/delete - Delete a user
module Authority::Dashboard::Users
  class DeleteEndpoint
    include SessionHelper
    include SecurityHeadersHelper
    include AdminAuthHelper
    include Endpoint(DeleteRequest, Response)

    post "/dashboard/users/:id/delete"

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

      # Delete the user
      result = AdminUserService.delete(
        id: delete_request.id,
        actor: admin_user
      )

      # Redirect back to users list regardless of result
      # (errors will show if user wasn't deleted)
      redirect to: "/dashboard/users", status: 302
    end
  end
end
