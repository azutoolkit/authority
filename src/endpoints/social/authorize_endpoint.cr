# Endpoint to initiate social OAuth flow
# Redirects user to the social provider's authorization page
module Authority::Social
  class AuthorizeEndpoint
    include SecurityHeadersHelper
    include SessionHelper
    include Endpoint(AuthorizeRequest, Response)

    get "/auth/:provider"

    def call : Response
      set_security_headers!

      provider = authorize_request.provider.downcase

      # Validate provider
      unless SocialConnection::Providers.valid?(provider)
        return error_redirect("Invalid provider: #{provider}")
      end

      # Check if provider is enabled
      unless SocialOAuthService.provider_enabled?(provider)
        return error_redirect("#{provider.capitalize} login is not enabled")
      end

      # Generate state parameter with forward URL
      forward_url = authorize_request.forward_url
      state = SocialOAuthService.generate_state(forward_url)

      # Build redirect URI (callback URL)
      host = ENV["APP_HOST"]? || "http://localhost:4000"
      redirect_uri = "#{host}/auth/#{provider}/callback"

      # Generate authorization URL
      auth_url = SocialOAuthService.authorization_url(
        provider,
        redirect_uri,
        state,
        forward_url
      )

      unless auth_url
        return error_redirect("Failed to generate authorization URL for #{provider}")
      end

      redirect to: auth_url, status: 302
    end

    private def error_redirect(message : String) : Response
      encoded_error = URI.encode_path_segment(message)
      redirect to: "/signin?error=#{encoded_error}", status: 302
    end
  end
end
