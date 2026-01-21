# Endpoint for Admin Client Regenerate Secret
# GET /dashboard/clients/:id/regenerate-secret - Show confirmation and new secret
module Authority::Dashboard::Clients
  class RegenerateSecretEndpoint
    include SessionHelper
    include SecurityHeadersHelper
    include Endpoint(RegenerateSecretRequest, SecretResponse | Response)

    get "/dashboard/clients/:id/regenerate-secret"

    def call : SecretResponse | Response
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

      # Regenerate the secret
      result, plain_secret = AdminClientService.regenerate_secret(
        id: params.id,
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
