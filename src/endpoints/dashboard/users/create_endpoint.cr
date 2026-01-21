# Endpoint for Admin User Create
# POST /dashboard/users - Create a new user
module Authority::Dashboard::Users
  class CreateEndpoint
    include SessionHelper
    include SecurityHeadersHelper
    include AdminAuthHelper
    include Endpoint(CreateRequest, ShowResponse | NewResponse | Response)

    post "/dashboard/users"

    def call : ShowResponse | NewResponse | Response
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

      # Validate required fields
      errors = [] of String
      errors << "Username is required" if create_request.username.empty?
      errors << "Email is required" if create_request.email.empty?
      errors << "Password is required" if create_request.password.empty?
      errors << "First name is required" if create_request.first_name.empty?
      errors << "Last name is required" if create_request.last_name.empty?

      unless errors.empty?
        return NewResponse.new(
          username: admin_user.username,
          errors: errors,
          form_username: create_request.username,
          email: create_request.email,
          first_name: create_request.first_name,
          last_name: create_request.last_name,
          role: create_request.role,
          scope: create_request.scope,
          email_verified: create_request.email_verified == "true"
        )
      end

      # Create the user
      result = AdminUserService.create(
        username: create_request.username,
        email: create_request.email,
        password: create_request.password,
        first_name: create_request.first_name,
        last_name: create_request.last_name,
        role: create_request.role,
        scope: create_request.scope,
        email_verified: create_request.email_verified == "true",
        actor: admin_user
      )

      unless result.success?
        return NewResponse.new(
          username: admin_user.username,
          errors: [result.error || "Failed to create user"],
          form_username: create_request.username,
          email: create_request.email,
          first_name: create_request.first_name,
          last_name: create_request.last_name,
          role: create_request.role,
          scope: create_request.scope,
          email_verified: create_request.email_verified == "true"
        )
      end

      created_user = result.user
      if created_user
        redirect to: "/dashboard/users/#{created_user.id}", status: 302
      else
        redirect to: "/dashboard/users", status: 302
      end
    end
  end
end
