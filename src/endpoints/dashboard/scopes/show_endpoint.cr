# Endpoint for Admin Scope Show page
# GET /dashboard/scopes/:id - Display scope details
module Authority::Dashboard::Scopes
  class ShowEndpoint
    include SessionHelper
    include SecurityHeadersHelper
    include AdminAuthHelper
    include Endpoint(ShowRequest, ShowResponse | Response)

    get "/dashboard/scopes/:id"

    def call : ShowResponse | Response
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

      # Get the scope
      scope = AdminScopeService.get(show_request.id)

      unless scope
        return redirect to: "/dashboard/scopes", status: 302
      end

      ShowResponse.new(
        scope: scope,
        username: user.username
      )
    end
  end
end
