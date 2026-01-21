# Endpoint for Admin Client Delete
# POST /dashboard/clients/:id/delete - Delete an OAuth client
module Authority::Dashboard::Clients
  class DeleteEndpoint
    include SessionHelper
    include SecurityHeadersHelper
    include Endpoint(DeleteRequest, Response)

    post "/dashboard/clients/:id/delete"

    def call : Response
      set_security_headers!

      # Check if user is authenticated
      return redirect_to_signin unless authenticated?

      # Get current user
      user = User.find!(current_session.user_id)

      # TODO: Add admin check once RBACService is implemented
      # return forbidden_response unless RBACService.admin?(user)

      # Delete the client
      result = AdminClientService.delete(
        id: params.id,
        actor: user
      )

      # Redirect back to clients list
      redirect to: "/dashboard/clients", status: 302
    end
  end
end
