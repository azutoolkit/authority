# Endpoint for Admin Client Create
# POST /dashboard/clients - Create a new OAuth client
module Authority::Dashboard::Clients
  class CreateEndpoint
    include SessionHelper
    include SecurityHeadersHelper
    include AdminAuthHelper
    include Endpoint(CreateRequest, SecretResponse | NewResponse | Response)

    post "/dashboard/clients"

    def call : SecretResponse | NewResponse | Response
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
      errors << "Redirect URI is required" if create_request.redirect_uri.empty?

      unless errors.empty?
        return NewResponse.new(
          username: user.username,
          errors: errors,
          name: create_request.name,
          redirect_uri: create_request.redirect_uri,
          description: create_request.description,
          logo: create_request.logo,
          scopes: create_request.scopes,
          policy_url: create_request.policy_url,
          tos_url: create_request.tos_url,
          is_confidential: create_request.is_confidential == "true"
        )
      end

      # Create the client
      result, plain_secret = AdminClientService.create_with_secret(
        name: create_request.name,
        redirect_uri: create_request.redirect_uri,
        description: create_request.description.empty? ? nil : create_request.description,
        logo: create_request.logo,
        scopes: create_request.scopes.empty? ? "read" : create_request.scopes,
        policy_url: create_request.policy_url.empty? ? nil : create_request.policy_url,
        tos_url: create_request.tos_url.empty? ? nil : create_request.tos_url,
        is_confidential: create_request.is_confidential == "true",
        actor: user
      )

      unless result.success?
        return NewResponse.new(
          username: user.username,
          errors: [result.error || "Failed to create client"],
          name: create_request.name,
          redirect_uri: create_request.redirect_uri,
          description: create_request.description,
          logo: create_request.logo,
          scopes: create_request.scopes,
          policy_url: create_request.policy_url,
          tos_url: create_request.tos_url,
          is_confidential: create_request.is_confidential == "true"
        )
      end

      client = result.client
      secret = plain_secret

      if client && secret
        SecretResponse.new(
          client: client,
          plain_secret: secret,
          username: user.username
        )
      else
        NewResponse.new(
          username: user.username,
          errors: ["Failed to create client"],
          name: create_request.name,
          redirect_uri: create_request.redirect_uri,
          description: create_request.description,
          logo: create_request.logo,
          scopes: create_request.scopes,
          policy_url: create_request.policy_url,
          tos_url: create_request.tos_url,
          is_confidential: create_request.is_confidential == "true"
        )
      end
    end
  end
end
