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
      set_html_headers!

      if auth_error = require_admin!
        return auth_error
      end

      user = current_admin_user
      return forbidden_response("Admin access required") unless user

      client = AdminClientService.get(update_request.id)
      return redirect(to: "/dashboard/clients", status: 302) unless client

      errors = validate_request
      return edit_response_with_errors(client, user, errors) unless errors.empty?

      result = perform_update(user)
      return edit_response_with_errors(client, user, [result.error || "Failed to update client"]) unless result.success?

      redirect to: "/dashboard/clients/#{update_request.id}", status: 302
    end

    private def set_html_headers!
      header "Content-Type", "text/html; charset=UTF-8"
      header "Cache-Control", "no-store"
      header "Pragma", "no-cache"
    end

    private def validate_request : Array(String)
      errors = [] of String
      errors << "Name is required" if update_request.name.empty?
      errors << "Redirect URI is required" if update_request.redirect_uri.empty?
      errors
    end

    private def perform_update(user : User)
      AdminClientService.update(
        id: update_request.id,
        name: update_request.name,
        redirect_uri: update_request.redirect_uri,
        description: empty_to_nil(update_request.description),
        logo: empty_to_nil(update_request.logo),
        scopes: empty_to_nil(update_request.scopes),
        policy_url: empty_to_nil(update_request.policy_url),
        tos_url: empty_to_nil(update_request.tos_url),
        is_confidential: update_request.is_confidential == "true",
        actor: user
      )
    end

    private def empty_to_nil(value : String) : String?
      value.empty? ? nil : value
    end

    private def edit_response_with_errors(client : Client, user : User, errors : Array(String)) : EditResponse
      apply_request_values_to_client(client)
      EditResponse.new(
        client: client,
        username: user.username,
        errors: errors
      )
    end

    private def apply_request_values_to_client(client : Client)
      client.name = update_request.name
      client.redirect_uri = update_request.redirect_uri
      client.description = empty_to_nil(update_request.description)
      client.logo = update_request.logo
      client.scopes = update_request.scopes
      client.policy_url = empty_to_nil(update_request.policy_url)
      client.tos_url = empty_to_nil(update_request.tos_url)
      client.is_confidential = update_request.is_confidential == "true"
    end
  end
end
