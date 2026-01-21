# Endpoint for Admin Scope Create
# POST /dashboard/scopes - Create a new scope
module Authority::Dashboard::Scopes
  class CreateEndpoint
    include SessionHelper
    include SecurityHeadersHelper
    include AdminAuthHelper
    include Endpoint(CreateRequest, NewResponse | Response)

    post "/dashboard/scopes"

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

      # Validate required fields
      errors = [] of String
      errors << "Name is required" if create_request.name.empty?
      errors << "Display name is required" if create_request.display_name.empty?

      unless errors.empty?
        return NewResponse.new(
          username: user.username,
          errors: errors,
          name: create_request.name,
          display_name: create_request.display_name,
          description: create_request.description,
          is_default: create_request.is_default == "true"
        )
      end

      # Create the scope
      result = AdminScopeService.create(
        name: create_request.name,
        display_name: create_request.display_name,
        description: create_request.description.empty? ? nil : create_request.description,
        is_default: create_request.is_default == "true",
        actor: user
      )

      unless result.success?
        return NewResponse.new(
          username: user.username,
          errors: [result.error || "Failed to create scope"],
          name: create_request.name,
          display_name: create_request.display_name,
          description: create_request.description,
          is_default: create_request.is_default == "true"
        )
      end

      created_scope = result.scope
      if created_scope
        redirect to: "/dashboard/scopes/#{created_scope.id}", status: 302
      else
        redirect to: "/dashboard/scopes", status: 302
      end
    end
  end
end
