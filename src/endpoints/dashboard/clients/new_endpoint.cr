# Endpoint for Admin Client New page
# GET /dashboard/clients/new - Display new client form
module Authority::Dashboard::Clients
  class NewEndpoint
    include SessionHelper
    include SecurityHeadersHelper
    include Endpoint(NewRequest, NewResponse | Response)

    get "/dashboard/clients/new"

    def call : NewResponse | Response
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

      NewResponse.new(username: user.username)
    end
  end
end
