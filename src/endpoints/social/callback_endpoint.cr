# Endpoint to handle social OAuth callback
# Exchanges authorization code for tokens and authenticates/creates user
module Authority::Social
  class CallbackEndpoint
    include SecurityHeadersHelper
    include SessionHelper
    include Endpoint(CallbackRequest, Response)

    get "/auth/:provider/callback"

    def call : Response
      set_security_headers!

      provider = callback_request.provider.downcase

      # Check for OAuth errors from provider
      if !callback_request.error.empty?
        error_msg = callback_request.error_description.empty? ?
          callback_request.error : callback_request.error_description
        return error_redirect("Authentication failed: #{error_msg}")
      end

      # Validate provider
      unless SocialConnection::Providers.valid?(provider)
        return error_redirect("Invalid provider: #{provider}")
      end

      # Check if provider is enabled
      unless SocialOAuthService.provider_enabled?(provider)
        return error_redirect("#{provider.capitalize} login is not enabled")
      end

      # Validate state parameter
      state = callback_request.state
      if state.empty?
        return error_redirect("Missing state parameter")
      end

      state_result = SocialOAuthService.validate_state(state)
      unless state_result[:valid]
        return error_redirect("Invalid or expired state parameter")
      end

      forward_url = state_result[:forward_url] || "/profile"

      # Validate authorization code
      code = callback_request.code
      if code.empty?
        return error_redirect("Missing authorization code")
      end

      # Build redirect URI
      host = ENV["APP_HOST"]? || "http://localhost:4000"
      redirect_uri = "#{host}/auth/#{provider}/callback"

      # Exchange code for tokens
      tokens = SocialOAuthService.exchange_code(provider, code, redirect_uri)
      unless tokens
        return error_redirect("Failed to exchange authorization code")
      end

      # Fetch user info from provider
      user_info = SocialOAuthService.fetch_user_info(provider, tokens.access_token, tokens.id_token)
      unless user_info
        return error_redirect("Failed to fetch user information from #{provider}")
      end

      # Check if this is linking to an existing authenticated session
      existing_user_id = nil
      if authenticated?
        user = current_user
        existing_user_id = user.id if user
      end

      # Authenticate or create user
      result = SocialOAuthService.authenticate_or_create(user_info, tokens, existing_user_id)

      unless result.success?
        return error_redirect(result.error || "Authentication failed")
      end

      user = result.user.not_nil!

      # Check if user is locked
      if user.locked?
        return error_redirect("Your account has been locked. Please contact support.")
      end

      # Create session - set session properties directly
      Authority.current_session.user_id = user.id.to_s
      Authority.current_session.email = user.email
      Authority.current_session.authenticated = true

      # Update last login info
      user.last_login_at = Time.utc
      user.last_login_ip = request_ip
      user.update!

      # Decode forward URL and redirect
      decoded_forward_url = begin
        Base64.decode_string(forward_url)
      rescue
        forward_url
      end

      # Ensure forward URL is safe (relative path)
      safe_forward_url = if decoded_forward_url.starts_with?("/")
                           decoded_forward_url
                         else
                           "/profile"
                         end

      redirect to: safe_forward_url, status: 302
    end

    private def error_redirect(message : String) : Response
      encoded_error = URI.encode_path_segment(message)
      redirect to: "/signin?error=#{encoded_error}", status: 302
    end

    private def current_user : User?
      user_id = Authority.current_session.user_id
      return nil unless user_id
      User.find(UUID.new(user_id))
    rescue
      nil
    end

    private def request_ip : String?
      # Try X-Forwarded-For first for proxied requests
      header["X-Forwarded-For"]?.try(&.split(",").first.strip) ||
        header["X-Real-IP"]? ||
        "unknown"
    end
  end
end
