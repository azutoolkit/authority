# Endpoint for Admin Client Create
# POST /dashboard/clients - Create a new OAuth client
module Authority::Dashboard::Clients
  class CreateEndpoint
    include SessionHelper
    include SecurityHeadersHelper
    include Endpoint(CreateRequest, SecretResponse | NewResponse | Response)

    post "/dashboard/clients"

    def call : SecretResponse | NewResponse | Response
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

      # Validate required fields
      errors = [] of String
      errors << "Name is required" if params.name.empty?
      errors << "Redirect URI is required" if params.redirect_uri.empty?

      unless errors.empty?
        return NewResponse.new(
          username: user.username,
          errors: errors,
          name: params.name,
          redirect_uri: params.redirect_uri,
          description: params.description,
          logo: params.logo,
          scopes: params.scopes,
          policy_url: params.policy_url,
          tos_url: params.tos_url,
          is_confidential: params.is_confidential == "true"
        )
      end

      # Create the client
      result, plain_secret = AdminClientService.create_with_secret(
        name: params.name,
        redirect_uri: params.redirect_uri,
        description: params.description.empty? ? nil : params.description,
        logo: params.logo,
        scopes: params.scopes.empty? ? "read" : params.scopes,
        policy_url: params.policy_url.empty? ? nil : params.policy_url,
        tos_url: params.tos_url.empty? ? nil : params.tos_url,
        is_confidential: params.is_confidential == "true",
        actor: user
      )

      unless result.success?
        return NewResponse.new(
          username: user.username,
          errors: [result.error || "Failed to create client"],
          name: params.name,
          redirect_uri: params.redirect_uri,
          description: params.description,
          logo: params.logo,
          scopes: params.scopes,
          policy_url: params.policy_url,
          tos_url: params.tos_url,
          is_confidential: params.is_confidential == "true"
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
          name: params.name,
          redirect_uri: params.redirect_uri,
          description: params.description,
          logo: params.logo,
          scopes: params.scopes,
          policy_url: params.policy_url,
          tos_url: params.tos_url,
          is_confidential: params.is_confidential == "true"
        )
      end
    end
  end
end
