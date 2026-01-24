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
      set_html_headers!

      if auth_error = require_admin!
        return auth_error
      end

      user = current_admin_user
      return forbidden_response("Admin access required") unless user

      errors = validate_request
      return new_response_with_errors(user, errors) unless errors.empty?

      result, plain_secret = create_client(user)
      return new_response_with_errors(user, [result.error || "Failed to create client"]) unless result.success?

      build_success_response(result.client, plain_secret, user)
    end

    private def set_html_headers!
      header "Content-Type", "text/html; charset=UTF-8"
      header "Cache-Control", "no-store"
      header "Pragma", "no-cache"
    end

    private def validate_request : Array(String)
      errors = [] of String
      errors << "Name is required" if create_request.name.empty?
      errors << "Redirect URI is required" if create_request.redirect_uri.empty?
      errors
    end

    private def create_client(user : User)
      AdminClientService.create_with_secret(
        name: create_request.name,
        redirect_uri: create_request.redirect_uri,
        description: empty_to_nil(create_request.description),
        logo: create_request.logo,
        scopes: create_request.scopes.empty? ? "read" : create_request.scopes,
        policy_url: empty_to_nil(create_request.policy_url),
        tos_url: empty_to_nil(create_request.tos_url),
        is_confidential: create_request.is_confidential == "true",
        actor: user
      )
    end

    private def empty_to_nil(value : String) : String?
      value.empty? ? nil : value
    end

    private def new_response_with_errors(user : User, errors : Array(String)) : NewResponse
      NewResponse.new(
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

    private def build_success_response(client : Client?, secret : String?, user : User) : SecretResponse | NewResponse
      if client && secret
        SecretResponse.new(
          client: client,
          plain_secret: secret,
          username: user.username
        )
      else
        new_response_with_errors(user, ["Failed to create client"])
      end
    end
  end
end
