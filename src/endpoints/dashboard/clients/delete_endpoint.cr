# Endpoint for Admin Client Delete
# POST /dashboard/clients/:id/delete - Delete an OAuth client
module Authority::Dashboard::Clients
  class DeleteEndpoint
    include SessionHelper
    include SecurityHeadersHelper
    include AdminAuthHelper
    include Endpoint(DeleteRequest, Response)

    post "/dashboard/clients/:id/delete"

    def call : Response
      set_security_headers!

      # Check admin authorization
      if auth_error = require_admin!
        return auth_error
      end

      user = current_admin_user
      return forbidden_response("Admin access required") unless user

      # Delete the client
      AdminClientService.delete(
        id: delete_request.id,
        actor: user
      )

      # Redirect back to clients list
      redirect to: "/dashboard/clients", status: 302
    end
  end
end
