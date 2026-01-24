# Social OAuth Service
# Handles OAuth 2.0 federation with social identity providers (Google, Facebook, Apple, LinkedIn, GitHub).
require "http/client"
require "json"
require "uri"
require "openssl/hmac"

module Authority
  class SocialOAuthService
    # Result struct for service operations
    struct AuthResult
      getter? success : Bool
      getter user : User?
      getter social_connection : SocialConnection?
      getter error : String?
      getter error_code : String?
      getter is_new_user : Bool

      def initialize(
        @success : Bool,
        @user : User? = nil,
        @social_connection : SocialConnection? = nil,
        @error : String? = nil,
        @error_code : String? = nil,
        @is_new_user : Bool = false
      )
      end
    end

    # User info from provider
    struct ProviderUserInfo
      getter provider : String
      getter provider_user_id : String
      getter email : String?
      getter email_verified : Bool
      getter name : String?
      getter first_name : String?
      getter last_name : String?
      getter avatar_url : String?
      getter raw_info : String

      def initialize(
        @provider : String,
        @provider_user_id : String,
        @email : String?,
        @email_verified : Bool,
        @name : String?,
        @first_name : String?,
        @last_name : String?,
        @avatar_url : String?,
        @raw_info : String
      )
      end
    end

    # Token response from provider
    struct TokenResponse
      getter access_token : String
      getter refresh_token : String?
      getter expires_in : Int64?
      getter token_type : String
      getter id_token : String?

      def initialize(
        @access_token : String,
        @refresh_token : String? = nil,
        @expires_in : Int64? = nil,
        @token_type : String = "Bearer",
        @id_token : String? = nil
      )
      end
    end

    # Provider configurations
    PROVIDER_CONFIGS = {
      SocialConnection::Providers::GOOGLE => {
        authorize_url:  "https://accounts.google.com/o/oauth2/v2/auth",
        token_url:      "https://oauth2.googleapis.com/token",
        userinfo_url:   "https://www.googleapis.com/oauth2/v3/userinfo",
        scopes:         "openid email profile",
        response_type:  "code",
      },
      SocialConnection::Providers::FACEBOOK => {
        authorize_url:  "https://www.facebook.com/v18.0/dialog/oauth",
        token_url:      "https://graph.facebook.com/v18.0/oauth/access_token",
        userinfo_url:   "https://graph.facebook.com/v18.0/me?fields=id,name,email,first_name,last_name,picture.type(large)",
        scopes:         "email,public_profile",
        response_type:  "code",
      },
      SocialConnection::Providers::APPLE => {
        authorize_url:  "https://appleid.apple.com/auth/authorize",
        token_url:      "https://appleid.apple.com/auth/token",
        userinfo_url:   "",  # Apple returns user info in ID token
        scopes:         "name email",
        response_type:  "code",
      },
      SocialConnection::Providers::LINKEDIN => {
        authorize_url:  "https://www.linkedin.com/oauth/v2/authorization",
        token_url:      "https://www.linkedin.com/oauth/v2/accessToken",
        userinfo_url:   "https://api.linkedin.com/v2/userinfo",
        scopes:         "openid profile email",
        response_type:  "code",
      },
      SocialConnection::Providers::GITHUB => {
        authorize_url:  "https://github.com/login/oauth/authorize",
        token_url:      "https://github.com/login/oauth/access_token",
        userinfo_url:   "https://api.github.com/user",
        scopes:         "user:email",
        response_type:  "code",
      },
    }

    # Generate authorization URL for a provider
    def self.authorization_url(
      provider : String,
      redirect_uri : String,
      state : String,
      forward_url : String? = nil
    ) : String?
      return nil unless SocialConnection::Providers.valid?(provider)
      provider = provider.downcase

      config = PROVIDER_CONFIGS[provider]?
      return nil unless config

      client_id = get_client_id(provider)
      return nil if client_id.nil? || client_id.empty?

      params = {
        "client_id"     => client_id,
        "redirect_uri"  => redirect_uri,
        "response_type" => config[:response_type],
        "scope"         => config[:scopes],
        "state"         => state,
      }

      # Apple requires response_mode=form_post
      if provider == SocialConnection::Providers::APPLE
        params["response_mode"] = "form_post"
      end

      query = params.map { |k, v| "#{k}=#{URI.encode_path_segment(v)}" }.join("&")
      "#{config[:authorize_url]}?#{query}"
    end

    # Exchange authorization code for tokens
    def self.exchange_code(
      provider : String,
      code : String,
      redirect_uri : String
    ) : TokenResponse?
      provider = provider.downcase
      config = PROVIDER_CONFIGS[provider]?
      return nil unless config

      client_id = get_client_id(provider)
      client_secret = get_client_secret(provider)
      return nil if client_id.nil? || client_secret.nil?

      body = {
        "grant_type"    => "authorization_code",
        "code"          => code,
        "redirect_uri"  => redirect_uri,
        "client_id"     => client_id,
        "client_secret" => client_secret,
      }

      # Apple needs special handling for client_secret (JWT)
      if provider == SocialConnection::Providers::APPLE
        apple_secret = generate_apple_client_secret
        return nil unless apple_secret
        body["client_secret"] = apple_secret
      end

      headers = HTTP::Headers{
        "Content-Type" => "application/x-www-form-urlencoded",
        "Accept"       => "application/json",
      }

      uri = URI.parse(config[:token_url])
      response = HTTP::Client.post(
        config[:token_url],
        headers: headers,
        body: URI::Params.encode(body)
      )

      return nil unless response.status.success?

      json = JSON.parse(response.body)

      TokenResponse.new(
        access_token: json["access_token"].as_s,
        refresh_token: json["refresh_token"]?.try(&.as_s),
        expires_in: json["expires_in"]?.try(&.as_i64),
        token_type: json["token_type"]?.try(&.as_s) || "Bearer",
        id_token: json["id_token"]?.try(&.as_s)
      )
    rescue
      nil
    end

    # Fetch user info from provider
    def self.fetch_user_info(
      provider : String,
      access_token : String,
      id_token : String? = nil
    ) : ProviderUserInfo?
      provider = provider.downcase

      case provider
      when SocialConnection::Providers::GOOGLE
        fetch_google_user_info(access_token)
      when SocialConnection::Providers::FACEBOOK
        fetch_facebook_user_info(access_token)
      when SocialConnection::Providers::APPLE
        fetch_apple_user_info(id_token)
      when SocialConnection::Providers::LINKEDIN
        fetch_linkedin_user_info(access_token)
      when SocialConnection::Providers::GITHUB
        fetch_github_user_info(access_token)
      else
        nil
      end
    end

    # Authenticate or create user from social login
    def self.authenticate_or_create(
      provider_info : ProviderUserInfo,
      tokens : TokenResponse,
      existing_user_id : UUID? = nil
    ) : AuthResult
      # First, check if we have an existing social connection
      existing_connection = SocialConnection.find_by_provider(
        provider_info.provider,
        provider_info.provider_user_id
      )

      if existing_connection
        # User already linked this social account
        user = User.find(existing_connection.user_id)
        return AuthResult.new(success: false, error: "User not found for social connection") unless user

        # Update token information
        update_connection_tokens(existing_connection, tokens)

        return AuthResult.new(
          success: true,
          user: user,
          social_connection: existing_connection,
          is_new_user: false
        )
      end

      # If linking to existing authenticated user
      if existing_user_id
        user = User.find(existing_user_id)
        return AuthResult.new(success: false, error: "User not found") unless user
        user_id = user.id
        return AuthResult.new(success: false, error: "User ID not found") unless user_id

        connection = create_social_connection(user_id, provider_info, tokens)
        return AuthResult.new(
          success: true,
          user: user,
          social_connection: connection,
          is_new_user: false
        )
      end

      # Check if email matches an existing user
      if email = provider_info.email
        existing_user = User.find_by(email: email)
        if existing_user
          existing_user_id_val = existing_user.id
          if existing_user_id_val
            # Link to existing account with matching email
            connection = create_social_connection(existing_user_id_val, provider_info, tokens)
            return AuthResult.new(
              success: true,
              user: existing_user,
              social_connection: connection,
              is_new_user: false
            )
          end
        end
      end

      # Create new user
      new_user_result = create_user_from_provider(provider_info)
      return AuthResult.new(success: false, error: new_user_result[:error]) unless new_user_result[:user]

      user = new_user_result[:user].not_nil!
      user_id = user.id
      return AuthResult.new(success: false, error: "Failed to create user") unless user_id
      connection = create_social_connection(user_id, provider_info, tokens)

      AuthResult.new(
        success: true,
        user: user,
        social_connection: connection,
        is_new_user: true
      )
    rescue e
      AuthResult.new(success: false, error: e.message)
    end

    # Unlink a social account from a user
    def self.unlink(user_id : UUID, provider : String) : AuthResult
      provider = provider.downcase

      connection = SocialConnection.query
        .where(user_id: user_id.to_s, provider: provider)
        .first

      return AuthResult.new(success: false, error: "Social connection not found") unless connection

      # Check if user has other login methods (password or other social accounts)
      user = User.find(user_id)
      return AuthResult.new(success: false, error: "User not found") unless user

      other_connections = SocialConnection.query
        .where(user_id: user_id.to_s)
        .count

      has_password = !user.encrypted_password.empty?

      if other_connections <= 1 && !has_password
        return AuthResult.new(
          success: false,
          error: "Cannot unlink last login method. Please set a password first."
        )
      end

      connection.delete!

      AuthResult.new(success: true)
    rescue e
      AuthResult.new(success: false, error: e.message)
    end

    # Check if a provider is enabled
    def self.provider_enabled?(provider : String) : Bool
      provider = provider.downcase
      key = case provider
            when SocialConnection::Providers::GOOGLE   then Setting::Keys::GOOGLE_OAUTH_ENABLED
            when SocialConnection::Providers::FACEBOOK then Setting::Keys::FACEBOOK_OAUTH_ENABLED
            when SocialConnection::Providers::APPLE    then Setting::Keys::APPLE_OAUTH_ENABLED
            when SocialConnection::Providers::LINKEDIN then Setting::Keys::LINKEDIN_OAUTH_ENABLED
            when SocialConnection::Providers::GITHUB   then Setting::Keys::GITHUB_OAUTH_ENABLED
            else return false
            end

      SettingsService.get_bool(key, false)
    end

    # Get all enabled providers
    def self.enabled_providers : Array(String)
      SocialConnection::Providers::ALL.select { |p| provider_enabled?(p) }
    end

    # Generate a secure state parameter
    def self.generate_state(forward_url : String? = nil) : String
      state_data = {
        "nonce"       => Random::Secure.hex(16),
        "timestamp"   => Time.utc.to_unix,
        "forward_url" => forward_url || "/profile",
      }
      Base64.urlsafe_encode(state_data.to_json)
    end

    # Validate and parse state parameter
    def self.validate_state(state : String) : NamedTuple(valid: Bool, forward_url: String?)
      decoded = Base64.decode_string(state)
      data = JSON.parse(decoded)

      timestamp = data["timestamp"].as_i64
      # State is valid for 10 minutes
      if Time.utc.to_unix - timestamp > 600
        return {valid: false, forward_url: nil}
      end

      {valid: true, forward_url: data["forward_url"]?.try(&.as_s)}
    rescue
      {valid: false, forward_url: nil}
    end

    # Private helper methods

    private def self.get_client_id(provider : String) : String?
      key = case provider
            when SocialConnection::Providers::GOOGLE   then Setting::Keys::GOOGLE_CLIENT_ID
            when SocialConnection::Providers::FACEBOOK then Setting::Keys::FACEBOOK_CLIENT_ID
            when SocialConnection::Providers::APPLE    then Setting::Keys::APPLE_CLIENT_ID
            when SocialConnection::Providers::LINKEDIN then Setting::Keys::LINKEDIN_CLIENT_ID
            when SocialConnection::Providers::GITHUB   then Setting::Keys::GITHUB_CLIENT_ID
            else return nil
            end
      SettingsService.get(key)
    end

    private def self.get_client_secret(provider : String) : String?
      key = case provider
            when SocialConnection::Providers::GOOGLE   then Setting::Keys::GOOGLE_CLIENT_SECRET
            when SocialConnection::Providers::FACEBOOK then Setting::Keys::FACEBOOK_CLIENT_SECRET
            when SocialConnection::Providers::APPLE    then Setting::Keys::APPLE_PRIVATE_KEY
            when SocialConnection::Providers::LINKEDIN then Setting::Keys::LINKEDIN_CLIENT_SECRET
            when SocialConnection::Providers::GITHUB   then Setting::Keys::GITHUB_CLIENT_SECRET
            else return nil
            end
      SettingsService.get(key)
    end

    private def self.generate_apple_client_secret : String?
      team_id = SettingsService.get(Setting::Keys::APPLE_TEAM_ID)
      key_id = SettingsService.get(Setting::Keys::APPLE_KEY_ID)
      client_id = SettingsService.get(Setting::Keys::APPLE_CLIENT_ID)
      private_key = SettingsService.get(Setting::Keys::APPLE_PRIVATE_KEY)

      return nil unless team_id && key_id && client_id && private_key

      # Apple requires a JWT as client_secret
      # Header: { "alg": "ES256", "kid": key_id }
      # Payload: { "iss": team_id, "iat": now, "exp": now + 6 months, "aud": "https://appleid.apple.com", "sub": client_id }
      # This is a simplified implementation - production should use a JWT library

      now = Time.utc.to_unix
      header = Base64.urlsafe_encode({"alg" => "ES256", "kid" => key_id}.to_json, padding: false)
      payload = Base64.urlsafe_encode({
        "iss" => team_id,
        "iat" => now,
        "exp" => now + (86400 * 180),  # 6 months
        "aud" => "https://appleid.apple.com",
        "sub" => client_id,
      }.to_json, padding: false)

      # Note: Actual signing would require ES256 implementation
      # For now, this returns a placeholder that would need proper JWT signing
      "#{header}.#{payload}.signature_placeholder"
    rescue
      nil
    end

    private def self.fetch_google_user_info(access_token : String) : ProviderUserInfo?
      config = PROVIDER_CONFIGS[SocialConnection::Providers::GOOGLE]
      headers = HTTP::Headers{"Authorization" => "Bearer #{access_token}"}

      response = HTTP::Client.get(config[:userinfo_url], headers: headers)
      return nil unless response.status.success?

      json = JSON.parse(response.body)

      ProviderUserInfo.new(
        provider: SocialConnection::Providers::GOOGLE,
        provider_user_id: json["sub"].as_s,
        email: json["email"]?.try(&.as_s),
        email_verified: json["email_verified"]?.try(&.as_bool) || false,
        name: json["name"]?.try(&.as_s),
        first_name: json["given_name"]?.try(&.as_s),
        last_name: json["family_name"]?.try(&.as_s),
        avatar_url: json["picture"]?.try(&.as_s),
        raw_info: response.body
      )
    rescue
      nil
    end

    private def self.fetch_facebook_user_info(access_token : String) : ProviderUserInfo?
      config = PROVIDER_CONFIGS[SocialConnection::Providers::FACEBOOK]
      url = "#{config[:userinfo_url]}&access_token=#{access_token}"

      response = HTTP::Client.get(url)
      return nil unless response.status.success?

      json = JSON.parse(response.body)

      avatar_url = json.dig?("picture", "data", "url").try(&.as_s)

      ProviderUserInfo.new(
        provider: SocialConnection::Providers::FACEBOOK,
        provider_user_id: json["id"].as_s,
        email: json["email"]?.try(&.as_s),
        email_verified: true,  # Facebook only returns verified emails
        name: json["name"]?.try(&.as_s),
        first_name: json["first_name"]?.try(&.as_s),
        last_name: json["last_name"]?.try(&.as_s),
        avatar_url: avatar_url,
        raw_info: response.body
      )
    rescue
      nil
    end

    private def self.fetch_apple_user_info(id_token : String?) : ProviderUserInfo?
      return nil unless id_token

      # Apple returns user info in the ID token (JWT)
      # Decode the JWT payload (middle part)
      parts = id_token.split(".")
      return nil if parts.size < 2

      payload = Base64.decode_string(parts[1] + "=" * (4 - parts[1].size % 4))
      json = JSON.parse(payload)

      ProviderUserInfo.new(
        provider: SocialConnection::Providers::APPLE,
        provider_user_id: json["sub"].as_s,
        email: json["email"]?.try(&.as_s),
        email_verified: json["email_verified"]?.try(&.as_bool) || json["email_verified"]?.try(&.as_s) == "true",
        name: nil,  # Apple may not provide name after first login
        first_name: nil,
        last_name: nil,
        avatar_url: nil,  # Apple doesn't provide avatar
        raw_info: payload
      )
    rescue
      nil
    end

    private def self.fetch_linkedin_user_info(access_token : String) : ProviderUserInfo?
      config = PROVIDER_CONFIGS[SocialConnection::Providers::LINKEDIN]
      headers = HTTP::Headers{"Authorization" => "Bearer #{access_token}"}

      response = HTTP::Client.get(config[:userinfo_url], headers: headers)
      return nil unless response.status.success?

      json = JSON.parse(response.body)

      ProviderUserInfo.new(
        provider: SocialConnection::Providers::LINKEDIN,
        provider_user_id: json["sub"].as_s,
        email: json["email"]?.try(&.as_s),
        email_verified: json["email_verified"]?.try(&.as_bool) || false,
        name: json["name"]?.try(&.as_s),
        first_name: json["given_name"]?.try(&.as_s),
        last_name: json["family_name"]?.try(&.as_s),
        avatar_url: json["picture"]?.try(&.as_s),
        raw_info: response.body
      )
    rescue
      nil
    end

    private def self.fetch_github_user_info(access_token : String) : ProviderUserInfo?
      config = PROVIDER_CONFIGS[SocialConnection::Providers::GITHUB]
      headers = HTTP::Headers{
        "Authorization" => "Bearer #{access_token}",
        "Accept"        => "application/vnd.github+json",
        "User-Agent"    => "Authority-OAuth-Server",
      }

      # Get user profile
      response = HTTP::Client.get(config[:userinfo_url], headers: headers)
      return nil unless response.status.success?

      json = JSON.parse(response.body)

      # GitHub might not return email in profile, need to fetch from /user/emails
      email = json["email"]?.try(&.as_s)
      email_verified = false

      if email.nil? || email.empty?
        emails_response = HTTP::Client.get("https://api.github.com/user/emails", headers: headers)
        if emails_response.status.success?
          emails = JSON.parse(emails_response.body).as_a
          primary_email = emails.find { |e| e["primary"]?.try(&.as_bool) == true }
          if primary_email
            email = primary_email["email"]?.try(&.as_s)
            email_verified = primary_email["verified"]?.try(&.as_bool) || false
          end
        end
      else
        email_verified = true  # If GitHub returns email in profile, it's verified
      end

      # Parse name into first/last
      full_name = json["name"]?.try(&.as_s)
      first_name, last_name = parse_name(full_name)

      ProviderUserInfo.new(
        provider: SocialConnection::Providers::GITHUB,
        provider_user_id: json["id"].as_i64.to_s,
        email: email,
        email_verified: email_verified,
        name: full_name,
        first_name: first_name,
        last_name: last_name,
        avatar_url: json["avatar_url"]?.try(&.as_s),
        raw_info: response.body
      )
    rescue
      nil
    end

    private def self.parse_name(full_name : String?) : Tuple(String?, String?)
      return {nil, nil} unless full_name
      parts = full_name.split(" ", 2)
      {parts[0]?, parts[1]?}
    end

    private def self.extract_first_name(full_name : String?) : String?
      return nil unless full_name
      parts = full_name.split(" ", 2)
      parts[0]?
    end

    private def self.extract_last_name(full_name : String?) : String?
      return nil unless full_name
      parts = full_name.split(" ", 2)
      parts[1]?
    end

    private def self.create_user_from_provider(info : ProviderUserInfo) : NamedTuple(user: User?, error: String?)
      # Generate a unique username from email or provider info
      base_username = if email = info.email
                        email.split("@").first
                      elsif name = info.name
                        name.downcase.gsub(/[^a-z0-9]/, "")
                      else
                        "#{info.provider}_user"
                      end

      username = generate_unique_username(base_username)

      user = User.new
      user.username = username
      user.email = info.email || "#{username}@social.auth"
      user.email_verified = info.email_verified
      user.first_name = info.first_name || extract_first_name(info.name) || "User"
      user.last_name = info.last_name || extract_last_name(info.name) || ""
      user.encrypted_password = ""  # No password for social-only accounts
      user.scope = "openid profile email"
      user.role = "user"
      user.created_at = Time.utc
      user.updated_at = Time.utc

      user.save!
      {user: user, error: nil}
    rescue e
      {user: nil, error: e.message}
    end

    private def self.generate_unique_username(base : String) : String
      username = base.downcase.gsub(/[^a-z0-9_]/, "")[0, 20]
      username = "user" if username.empty?

      return username unless User.find_by(username: username)

      # Add random suffix if username exists
      loop do
        candidate = "#{username}#{Random.rand(1000..9999)}"
        return candidate unless User.find_by(username: candidate)
      end
    end

    private def self.create_social_connection(
      user_id : UUID,
      info : ProviderUserInfo,
      tokens : TokenResponse
    ) : SocialConnection
      connection = SocialConnection.new
      connection.user_id = user_id
      connection.provider = info.provider
      connection.provider_user_id = info.provider_user_id
      connection.email = info.email
      connection.name = info.name
      connection.avatar_url = info.avatar_url
      connection.access_token = tokens.access_token
      connection.refresh_token = tokens.refresh_token
      connection.token_expires_at = tokens.expires_in.try { |exp| Time.utc + exp.seconds }
      connection.raw_info = info.raw_info
      connection.created_at = Time.utc
      connection.updated_at = Time.utc

      connection.save!
      connection
    end

    private def self.update_connection_tokens(connection : SocialConnection, tokens : TokenResponse)
      connection.access_token = tokens.access_token
      connection.refresh_token = tokens.refresh_token if tokens.refresh_token
      connection.token_expires_at = tokens.expires_in.try { |exp| Time.utc + exp.seconds }
      connection.updated_at = Time.utc
      connection.update!
    end
  end
end
