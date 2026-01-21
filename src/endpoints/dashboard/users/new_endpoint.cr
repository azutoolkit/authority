# Endpoint for Admin User New page
# GET /dashboard/users/new - Display user creation form
module Authority::Dashboard::Users
  class NewEndpoint
    include SessionHelper
    include SecurityHeadersHelper
    include AdminAuthHelper
    include Endpoint(NewRequest, NewResponse | Response)

    get "/dashboard/users/new"

    def call : NewResponse | Response
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

      NewResponse.new(username: user.username)
    end
  end
end
