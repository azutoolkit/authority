# Endpoint for Admin Users List page
# GET /dashboard/users - Display list of users with filters
module Authority::Dashboard::Users
  class IndexEndpoint
    include SessionHelper
    include SecurityHeadersHelper
    include AdminAuthHelper
    include Endpoint(IndexRequest, IndexResponse | Response)

    get "/dashboard/users"

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

      # Get pagination and filter params
      page = index_request.page > 0 ? index_request.page : 1
      search = index_request.search
      status = index_request.status
      role = index_request.role

      # Build list options
      options = AdminUserService::ListOptions.new(
        page: page,
        per_page: 20,
        search: search.empty? ? nil : search,
        status: status.empty? ? nil : status,
        role: role.empty? ? nil : role
      )

      # Fetch users using the admin service
      users = AdminUserService.list(options)
      total_count = AdminUserService.count(options)

      IndexResponse.new(
        users: users,
        page: page,
        per_page: 20,
        total_count: total_count,
        search: search,
        status: status,
        role: role,
        username: user.username
      )
    end
  end
end
