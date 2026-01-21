# Endpoint for Admin Client Regenerate Secret
# GET /dashboard/clients/:id/regenerate-secret - Show confirmation and new secret
module Authority::Dashboard::Clients
  class RegenerateSecretEndpoint
    include SessionHelper
    include SecurityHeadersHelper
    include AdminAuthHelper
    include Endpoint(RegenerateSecretRequest, SecretResponse | Response)

    get "/dashboard/clients/:id/regenerate-secret"

    def call : SecretResponse | Response
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

      # Regenerate the secret
      result, plain_secret = AdminClientService.regenerate_secret(
        id: regenerate_secret_request.id,
        actor: user
      )

      unless result.success?
        return redirect to: "/dashboard/clients", status: 302
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
        redirect to: "/dashboard/clients", status: 302
      end
    end
  end
end
