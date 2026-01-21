# Endpoint for Admin User Update
# POST /dashboard/users/:id - Update user details
module Authority::Dashboard::Users
  class UpdateEndpoint
    include SessionHelper
    include SecurityHeadersHelper
    include AdminAuthHelper
    include Endpoint(UpdateRequest, EditResponse | Response)

    post "/dashboard/users/:id"

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

      # Get existing user
      target_user = AdminUserService.get(update_request.id)

      unless target_user
        return redirect to: "/dashboard/users", status: 302
      end

      # Validate required fields
      errors = [] of String
      errors << "Username is required" if update_request.username.empty?
      errors << "Email is required" if update_request.email.empty?
      errors << "First name is required" if update_request.first_name.empty?
      errors << "Last name is required" if update_request.last_name.empty?

      unless errors.empty?
        # Update user object with submitted values for re-display
        target_user.username = update_request.username
        target_user.email = update_request.email
        target_user.first_name = update_request.first_name
        target_user.last_name = update_request.last_name
        target_user.role = update_request.role
        target_user.scope = update_request.scope
        target_user.email_verified = update_request.email_verified == "true"

        return EditResponse.new(
          user: target_user,
          username: admin_user.username,
          errors: errors
        )
      end

      # Update the user
      result = AdminUserService.update(
        id: update_request.id,
        username: update_request.username,
        email: update_request.email,
        first_name: update_request.first_name,
        last_name: update_request.last_name,
        role: update_request.role,
        scope: update_request.scope.empty? ? nil : update_request.scope,
        email_verified: update_request.email_verified == "true",
        actor: admin_user
      )

      unless result.success?
        return EditResponse.new(
          user: target_user,
          username: admin_user.username,
          errors: [result.error || "Failed to update user"]
        )
      end

      # Redirect to show page on success
      redirect to: "/dashboard/users/#{update_request.id}", status: 302
    end
  end
end
