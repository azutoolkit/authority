# Endpoint for Admin Scope Delete
# POST /dashboard/scopes/:id/delete - Delete a scope
module Authority::Dashboard::Scopes
  class DeleteEndpoint
    include SessionHelper
    include SecurityHeadersHelper
    include AdminAuthHelper
    include Endpoint(DeleteRequest, Response)

    post "/dashboard/scopes/:id/delete"

    def call : Response
      set_security_headers!
      header "Content-Type", "text/html; charset=UTF-8"
      header "Cache-Control", "no-store"
      header "Pragma", "no-cache"

      # Check admin authorization
      if auth_error = require_admin!
        return auth_error
      end

      user = current_admin_user
      return forbidden_response("Admin access required") unless user

      # Delete the scope (service handles system scope protection)
      AdminScopeService.delete(
        id: delete_request.id,
        actor: user
      )

      # Redirect back to scopes list
      redirect to: "/dashboard/scopes", status: 302
    end
  end
end
