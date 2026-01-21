# Endpoint for Admin Client Update
# POST /dashboard/clients/:id - Update an existing OAuth client
module Authority::Dashboard::Clients
  class UpdateEndpoint
    include SessionHelper
    include SecurityHeadersHelper
    include AdminAuthHelper
    include Endpoint(UpdateRequest, EditResponse | Response)

    post "/dashboard/clients/:id"

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

      # Get existing client
      client = AdminClientService.get(update_request.id)

      unless client
        return redirect to: "/dashboard/clients", status: 302
      end

      # Validate required fields
      errors = [] of String
      errors << "Name is required" if update_request.name.empty?
      errors << "Redirect URI is required" if update_request.redirect_uri.empty?

      unless errors.empty?
        # Update client object with submitted values for re-display
        client.name = update_request.name
        client.redirect_uri = update_request.redirect_uri
        client.description = update_request.description.empty? ? nil : update_request.description
        client.logo = update_request.logo
        client.scopes = update_request.scopes
        client.policy_url = update_request.policy_url.empty? ? nil : update_request.policy_url
        client.tos_url = update_request.tos_url.empty? ? nil : update_request.tos_url
        client.is_confidential = update_request.is_confidential == "true"

        return EditResponse.new(
          client: client,
          username: user.username,
          errors: errors
        )
      end

      # Update the client
      result = AdminClientService.update(
        id: update_request.id,
        name: update_request.name,
        redirect_uri: update_request.redirect_uri,
        description: update_request.description.empty? ? nil : update_request.description,
        logo: update_request.logo.empty? ? nil : update_request.logo,
        scopes: update_request.scopes.empty? ? nil : update_request.scopes,
        policy_url: update_request.policy_url.empty? ? nil : update_request.policy_url,
        tos_url: update_request.tos_url.empty? ? nil : update_request.tos_url,
        is_confidential: update_request.is_confidential == "true",
        actor: user
      )

      unless result.success?
        return EditResponse.new(
          client: client,
          username: user.username,
          errors: [result.error || "Failed to update client"]
        )
      end

      # Redirect to show page on success
      redirect to: "/dashboard/clients/#{update_request.id}", status: 302
    end
  end
end
