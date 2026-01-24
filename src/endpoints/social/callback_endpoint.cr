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

      return handle_oauth_error if oauth_error?
      return error_redirect("Invalid provider: #{provider}") unless valid_provider?(provider)
      return error_redirect("#{provider.capitalize} login is not enabled") unless provider_enabled?(provider)

      forward_url = validate_state_and_get_forward_url
      return forward_url if forward_url.is_a?(Response)

      return error_redirect("Missing authorization code") if callback_request.code.empty?

      user = authenticate_user(provider)
      return user if user.is_a?(Response)

      create_session_and_redirect(user, forward_url)
    end

    private def oauth_error? : Bool
      !callback_request.error.empty?
    end

    private def handle_oauth_error : Response
      error_msg = callback_request.error_description.empty? ? callback_request.error : callback_request.error_description
      error_redirect("Authentication failed: #{error_msg}")
    end

    private def valid_provider?(provider : String) : Bool
      SocialConnection::Providers.valid?(provider)
    end

    private def provider_enabled?(provider : String) : Bool
      SocialOAuthService.provider_enabled?(provider)
    end

    private def validate_state_and_get_forward_url : String | Response
      state = callback_request.state
      return error_redirect("Missing state parameter") if state.empty?

      state_result = SocialOAuthService.validate_state(state)
      return error_redirect("Invalid or expired state parameter") unless state_result[:valid]

      state_result[:forward_url] || "/profile"
    end

    private def authenticate_user(provider : String) : User | Response
      tokens = exchange_code_for_tokens(provider)
      return error_redirect("Failed to exchange authorization code") unless tokens

      user_info = fetch_user_info(provider, tokens)
      return error_redirect("Failed to fetch user information from #{provider}") unless user_info

      result = SocialOAuthService.authenticate_or_create(user_info, tokens, existing_user_id)
      return error_redirect(result.error || "Authentication failed") unless result.success?

      user = result.user
      return error_redirect("Authentication failed - no user returned") unless user
      return error_redirect("Your account has been locked. Please contact support.") if user.locked?

      user
    end

    private def exchange_code_for_tokens(provider : String)
      host = ENV["APP_HOST"]? || "http://localhost:4000"
      redirect_uri = "#{host}/auth/#{provider}/callback"
      SocialOAuthService.exchange_code(provider, callback_request.code, redirect_uri)
    end

    private def fetch_user_info(provider : String, tokens)
      SocialOAuthService.fetch_user_info(provider, tokens.access_token, tokens.id_token)
    end

    private def existing_user_id : UUID?
      return nil unless authenticated?
      current_user.try(&.id)
    end

    private def create_session_and_redirect(user : User, forward_url : String) : Response
      Authority.current_session.user_id = user.id.to_s
      Authority.current_session.email = user.email
      Authority.current_session.authenticated = true

      update_last_login(user)

      redirect to: safe_forward_url(forward_url), status: 302
    end

    private def update_last_login(user : User)
      user.last_login_at = Time.utc
      user.last_login_ip = request_ip
      user.update!
    end

    private def safe_forward_url(forward_url : String) : String
      decoded = decode_forward_url(forward_url)
      decoded.starts_with?("/") ? decoded : "/profile"
    end

    private def decode_forward_url(forward_url : String) : String
      Base64.decode_string(forward_url)
    rescue
      forward_url
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
      header["X-Forwarded-For"]?.try(&.split(",").first.strip) ||
        header["X-Real-IP"]? ||
        "unknown"
    end
  end
end
