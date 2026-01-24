# Endpoint for Admin User Show page
# GET /dashboard/users/:id - Display user details
module Authority::Dashboard::Users
  class ShowEndpoint
    include SessionHelper
    include SecurityHeadersHelper
    include AdminAuthHelper
    include Endpoint(ShowRequest, ShowResponse | Response)

    get "/dashboard/users/:id"

    def call : ShowResponse | Response
      set_security_headers!
      header "Content-Type", "text/html; charset=UTF-8"
      header "Cache-Control", "no-store"
      header "Pragma", "no-cache"

      # Check admin authorization
      if auth_error = require_admin!
        return auth_error
      end

      admin_user = current_admin_user
      return forbidden_response("Admin access required") unless admin_user

      # Get the user
      target_user = AdminUserService.get(show_request.id)

      unless target_user
        return redirect to: "/dashboard/users", status: 302
      end

      # Fetch active sessions for this user
      sessions = SessionManagementService.list_for_user(target_user.id.to_s)

      ShowResponse.new(
        user: target_user,
        sessions: sessions,
        username: admin_user.username
      )
    end
  end
end
