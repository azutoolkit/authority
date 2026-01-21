# Endpoint for Admin User Edit page
# GET /dashboard/users/:id/edit - Display user edit form
module Authority::Dashboard::Users
  class EditEndpoint
    include SessionHelper
    include SecurityHeadersHelper
    include AdminAuthHelper
    include Endpoint(EditRequest, EditResponse | Response)

    get "/dashboard/users/:id/edit"

    def call : EditResponse | Response
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
      target_user = AdminUserService.get(edit_request.id)

      unless target_user
        return redirect to: "/dashboard/users", status: 302
      end

      EditResponse.new(
        user: target_user,
        username: admin_user.username
      )
    end
  end
end
