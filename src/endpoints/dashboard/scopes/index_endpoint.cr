# Endpoint for Admin Scopes List page
# GET /dashboard/scopes - Display list of OAuth scopes
module Authority::Dashboard::Scopes
  class IndexEndpoint
    include SessionHelper
    include SecurityHeadersHelper
    include AdminAuthHelper
    include Endpoint(IndexRequest, IndexResponse | Response)

    get "/dashboard/scopes"

    def call : IndexResponse | Response
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

      # Get pagination params
      page = index_request.page > 0 ? index_request.page : 1

      # Fetch scopes using the admin service
      scopes = AdminScopeService.list(page: page, per_page: 20)

      IndexResponse.new(
        scopes: scopes,
        page: page,
        per_page: 20,
        username: user.username
      )
    end
  end
end
