# Endpoint for Admin Client Edit page
# GET /dashboard/clients/:id/edit - Display client edit form
module Authority::Dashboard::Clients
  class EditEndpoint
    include SessionHelper
    include SecurityHeadersHelper
    include Endpoint(EditRequest, EditResponse | Response)

    get "/dashboard/clients/:id/edit"

    def call : EditResponse | Response
      set_security_headers!
      header "Content-Type", "text/html; charset=UTF-8"
      header "Cache-Control", "no-store"
      header "Pragma", "no-cache"

      # Check if user is authenticated
      return redirect_to_signin unless authenticated?

      # Get current user
      user = User.find!(current_session.user_id)

      # TODO: Add admin check once RBACService is implemented
      # return forbidden_response unless RBACService.admin?(user)

      # Get the client
      client = AdminClientService.get(params.id)

      unless client
        return redirect to: "/dashboard/clients", status: 302
      end

      EditResponse.new(
        client: client,
        username: user.username
      )
    end
  end
end
