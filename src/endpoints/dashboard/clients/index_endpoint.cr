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

      # Get pagination and filter params
      page = index_request.page > 0 ? index_request.page : 1
      per_page = 20

      # Build filter options
      options = AdminClientService::ListOptions.new(
        page: page,
        per_page: per_page,
        search: index_request.search.empty? ? nil : index_request.search,
        confidentiality: index_request.confidentiality.empty? ? nil : index_request.confidentiality,
        scope: index_request.scope.empty? ? nil : index_request.scope,
        sort_by: index_request.sort_by,
        sort_dir: index_request.sort_dir
      )

      # Fetch clients using the admin service
      clients = AdminClientService.list(options)
      total_count = AdminClientService.count(options)

      # Get available scopes for filter dropdown
      available_scopes = AdminScopeService.list(page: 1, per_page: 100).map(&.name)

      IndexResponse.new(
        clients: clients,
        page: page,
        per_page: per_page,
        total_count: total_count,
        search: index_request.search,
        confidentiality: index_request.confidentiality,
        scope_filter: index_request.scope,
        sort_by: index_request.sort_by,
        sort_dir: index_request.sort_dir,
        available_scopes: available_scopes,
        username: user.username
      )
    end
  end
end
