# RFC 7591 Dynamic Client Registration Endpoint
# POST /register - Register a new OAuth 2.0 client
module Authority::Register
  class CreateEndpoint
    include Endpoint(CreateRequest, Authority::ClientRegistrationResponse | Authority::RegistrationErrorResponse)

    post "/register"

    def call : Authority::ClientRegistrationResponse | Authority::RegistrationErrorResponse
      header "Content-Type", "application/json"
      header "Cache-Control", "no-store"
      header "Pragma", "no-cache"

      # Validate request
      return invalid_client_metadata("redirect_uris is required") if request.redirect_uris.empty?
      return invalid_redirect_uri if request.redirect_uri_error?
      return invalid_client_metadata("Unsupported grant_types") if request.grant_type_error?
      return invalid_client_metadata("Unsupported response_types") if request.response_type_error?
      return invalid_client_metadata("Unsupported token_endpoint_auth_method") if request.auth_method_error?

      # Create client
      client = create_client

      status 201
      Authority::ClientRegistrationResponse.new(
        client_id: client.client_id,
        client_secret: request.public_client? ? nil : client.client_secret,
        client_id_issued_at: Time.utc.to_unix,
        client_secret_expires_at: 0_i64,  # Never expires
        client_name: client.name,
        redirect_uris: request.redirect_uris,
        token_endpoint_auth_method: request.token_endpoint_auth_method,
        grant_types: request.grant_types,
        response_types: request.response_types,
        scope: request.scope.empty? ? nil : request.scope,
        logo_uri: request.logo_uri.empty? ? nil : request.logo_uri,
        client_uri: request.client_uri.empty? ? nil : request.client_uri,
        contacts: request.contacts.empty? ? nil : request.contacts,
        tos_uri: request.tos_uri.empty? ? nil : request.tos_uri,
        policy_uri: request.policy_uri.empty? ? nil : request.policy_uri
      )
    end

    private def create_client : Client
      client = Client.new
      client.name = request.client_name.empty? ? "Unnamed Client" : request.client_name
      client.client_id = UUID.random.to_s
      client.client_secret = request.public_client? ? "" : Base64.urlsafe_encode(Random::Secure.hex(32), false)
      client.redirect_uri = request.redirect_uris.first  # Store primary redirect URI
      client.description = request.client_uri
      client.logo = request.logo_uri
      client.scopes = request.scope.empty? ? "read" : request.scope
      client.save!
      client
    end

    private def request : CreateRequest
      create_request
    end

    private def invalid_client_metadata(description : String) : Authority::RegistrationErrorResponse
      status 400
      Authority::RegistrationErrorResponse.new("invalid_client_metadata", description)
    end

    private def invalid_redirect_uri : Authority::RegistrationErrorResponse
      status 400
      Authority::RegistrationErrorResponse.new("invalid_redirect_uri", "redirect_uri must use https scheme and cannot contain fragments")
    end
  end
end
