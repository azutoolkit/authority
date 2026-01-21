# Endpoint for Admin Scope Edit page
# GET /dashboard/scopes/:id/edit - Display scope edit form
module Authority::Dashboard::Scopes
  class EditEndpoint
    include SessionHelper
    include SecurityHeadersHelper
    include AdminAuthHelper
    include Endpoint(EditRequest, EditResponse | Response)

    get "/dashboard/scopes/:id/edit"

    def call : EditResponse | Response
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
      scope = AdminScopeService.get(edit_request.id)

      unless scope
        return redirect to: "/dashboard/scopes", status: 302
      end

      # Prevent editing system scopes
      if scope.is_system?
        return redirect to: "/dashboard/scopes/#{scope.id}", status: 302
      end

      EditResponse.new(
        scope: scope,
        username: user.username
      )
    end
  end
end
