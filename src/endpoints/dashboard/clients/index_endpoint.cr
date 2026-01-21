# Endpoint for Admin Clients List page
# GET /dashboard/clients - Display list of OAuth clients
module Authority::Dashboard::Clients
  class IndexEndpoint
    include SessionHelper
    include SecurityHeadersHelper
    include Endpoint(IndexRequest, IndexResponse | Response)

    get "/dashboard/clients"

    def call : IndexResponse | Response
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

      # Get pagination params
      page = params.page > 0 ? params.page : 1

      # Fetch clients using the admin service
      clients = AdminClientService.list(page: page, per_page: 20)

      IndexResponse.new(
        clients: clients,
        page: page,
        per_page: 20,
        username: user.username
      )
    end
  end
end
