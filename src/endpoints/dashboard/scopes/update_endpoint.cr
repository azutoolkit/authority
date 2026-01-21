# Endpoint for Admin Scope Update
# POST /dashboard/scopes/:id - Update scope details
module Authority::Dashboard::Scopes
  class UpdateEndpoint
    include SessionHelper
    include SecurityHeadersHelper
    include AdminAuthHelper
    include Endpoint(UpdateRequest, EditResponse | Response)

    post "/dashboard/scopes/:id"

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

      # Get existing scope
      scope = AdminScopeService.get(update_request.id)

      unless scope
        return redirect to: "/dashboard/scopes", status: 302
      end

      # Prevent updating system scopes
      if scope.is_system?
        return redirect to: "/dashboard/scopes/#{scope.id}", status: 302
      end

      # Validate required fields
      errors = [] of String
      errors << "Name is required" if update_request.name.empty?
      errors << "Display name is required" if update_request.display_name.empty?

      unless errors.empty?
        scope.name = update_request.name
        scope.display_name = update_request.display_name
        scope.description = update_request.description.empty? ? nil : update_request.description
        scope.is_default = update_request.is_default == "true"

        return EditResponse.new(
          scope: scope,
          username: user.username,
          errors: errors
        )
      end

      # Update the scope
      result = AdminScopeService.update(
        id: update_request.id,
        name: update_request.name,
        display_name: update_request.display_name,
        description: update_request.description.empty? ? nil : update_request.description,
        is_default: update_request.is_default == "true",
        actor: user
      )

      unless result.success?
        return EditResponse.new(
          scope: scope,
          username: user.username,
          errors: [result.error || "Failed to update scope"]
        )
      end

      # Redirect to show page on success
      redirect to: "/dashboard/scopes/#{update_request.id}", status: 302
    end
  end
end
