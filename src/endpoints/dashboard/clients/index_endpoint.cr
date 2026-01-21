# Endpoint for Admin Clients List page
# GET /dashboard/clients - Display list of OAuth clients
module Authority::Dashboard::Clients
  class IndexEndpoint
    include SessionHelper
    include SecurityHeadersHelper
    include AdminAuthHelper
    include Endpoint(IndexRequest, IndexResponse | Response)

    get "/dashboard/clients"

    def call : IndexResponse | Response
      set_security_headers!
      header "Content-Type", "text/html; charset=UTF-8"
      header "Cache-Control", "no-store"
      header "Pragma", "no-cache"

      # Check admin authorization (IP allowlist + auth + RBAC)
      if auth_error = require_admin!
        return auth_error
      end

      user = current_admin_user
      return forbidden_response("Admin access required") unless user

      # Get pagination params
      page = index_request.page > 0 ? index_request.page : 1

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
