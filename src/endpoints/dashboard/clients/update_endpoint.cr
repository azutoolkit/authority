# Endpoint for Admin Client Update
# POST /dashboard/clients/:id - Update an existing OAuth client
module Authority::Dashboard::Clients
  class UpdateEndpoint
    include SessionHelper
    include SecurityHeadersHelper
    include Endpoint(UpdateRequest, EditResponse | Response)

    post "/dashboard/clients/:id"

    def call : EditResponse | Response
      set_security_headers!
      header "Content-Type", "text/html; charset=UTF-8"
      header "Cache-Control", "no-store"
      header "Pragma", "no-cache"

      # Check if user is authenticated
      return redirect_to_signin unless authenticated?

      # Get current user
      user = User.find!(current_session.user_id)

      # TODO: Add admin check once RBACService is implemented
      # return forbidden_response unless RBACService.admin?(user)

      # Get existing client
      client = AdminClientService.get(params.id)

      unless client
        return redirect to: "/dashboard/clients", status: 302
      end

      # Validate required fields
      errors = [] of String
      errors << "Name is required" if params.name.empty?
      errors << "Redirect URI is required" if params.redirect_uri.empty?

      unless errors.empty?
        # Update client object with submitted values for re-display
        client.name = params.name
        client.redirect_uri = params.redirect_uri
        client.description = params.description.empty? ? nil : params.description
        client.logo = params.logo
        client.scopes = params.scopes
        client.policy_url = params.policy_url.empty? ? nil : params.policy_url
        client.tos_url = params.tos_url.empty? ? nil : params.tos_url
        client.is_confidential = params.is_confidential == "true"

        return EditResponse.new(
          client: client,
          username: user.username,
          errors: errors
        )
      end

      # Update the client
      result = AdminClientService.update(
        id: params.id,
        name: params.name,
        redirect_uri: params.redirect_uri,
        description: params.description.empty? ? nil : params.description,
        logo: params.logo.empty? ? nil : params.logo,
        scopes: params.scopes.empty? ? nil : params.scopes,
        policy_url: params.policy_url.empty? ? nil : params.policy_url,
        tos_url: params.tos_url.empty? ? nil : params.tos_url,
        is_confidential: params.is_confidential == "true",
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
      redirect to: "/dashboard/clients/#{params.id}", status: 302
    end
  end
end
