# Endpoint for User Profile page
# GET /profile - Display the user profile
module Authority::Profile
  PROFILE_PATH = "/profile"

  class ShowEndpoint
    include SessionHelper
    include SecurityHeadersHelper
    include Endpoint(ShowRequest, ProfileResponse | Response)

    get PROFILE_PATH

    def call : ProfileResponse | Response
      set_security_headers!
      set_html_headers!

      return redirect_to_signin unless authenticated?

      user = OwnerRepo.find_by_id(current_session.user_id)
      return redirect_to_signin unless user

      build_profile_response(user)
    end

    private def set_html_headers!
      header "Content-Type", "text/html; charset=UTF-8"
      header "Cache-Control", "no-store"
      header "Pragma", "no-cache"
    end

    private def build_profile_response(user) : ProfileResponse
      provider_status = fetch_provider_status
      connections = fetch_social_connections(user)

      ProfileResponse.new(
        first_name: user.first_name,
        last_name: user.last_name,
        email: user.email,
        username: user.username,
        email_verified: user.email_verified?,
        mfa_enabled: user.mfa_enabled?,
        created_at: user.created_at.try(&.to_s("%B %d, %Y")) || "",
        last_login: user.updated_at.try(&.to_s("%B %d, %Y %H:%M")) || "",
        connected_apps: [] of ConnectedApp,
        forward_url: "/profile",
        social_providers_enabled: provider_status[:any_enabled],
        google_enabled: provider_status[:google],
        github_enabled: provider_status[:github],
        facebook_enabled: provider_status[:facebook],
        apple_enabled: provider_status[:apple],
        linkedin_enabled: provider_status[:linkedin],
        google_connected: connections[:google_connected],
        google_email: connections[:google_email],
        github_connected: connections[:github_connected],
        github_email: connections[:github_email],
        facebook_connected: connections[:facebook_connected],
        facebook_email: connections[:facebook_email],
        apple_connected: connections[:apple_connected],
        apple_email: connections[:apple_email],
        linkedin_connected: connections[:linkedin_connected],
        linkedin_email: connections[:linkedin_email]
      )
    end

    private def fetch_provider_status : NamedTuple(
      google: Bool, github: Bool, facebook: Bool, apple: Bool, linkedin: Bool, any_enabled: Bool)
      google = SocialOAuthService.provider_enabled?("google")
      github = SocialOAuthService.provider_enabled?("github")
      facebook = SocialOAuthService.provider_enabled?("facebook")
      apple = SocialOAuthService.provider_enabled?("apple")
      linkedin = SocialOAuthService.provider_enabled?("linkedin")

      {
        google:      google,
        github:      github,
        facebook:    facebook,
        apple:       apple,
        linkedin:    linkedin,
        any_enabled: google || github || facebook || apple || linkedin,
      }
    end

    private def fetch_social_connections(user) : NamedTuple(
      google_connected: Bool, google_email: String,
      github_connected: Bool, github_email: String,
      facebook_connected: Bool, facebook_email: String,
      apple_connected: Bool, apple_email: String,
      linkedin_connected: Bool, linkedin_email: String)
      user_id = user.id
      connections = user_id ? SocialConnection.find_by_user(user_id) : [] of SocialConnection

      {
        google_connected:   connection_exists?(connections, "google"),
        google_email:       connection_email(connections, "google"),
        github_connected:   connection_exists?(connections, "github"),
        github_email:       connection_email(connections, "github"),
        facebook_connected: connection_exists?(connections, "facebook"),
        facebook_email:     connection_email(connections, "facebook"),
        apple_connected:    connection_exists?(connections, "apple"),
        apple_email:        connection_email(connections, "apple"),
        linkedin_connected: connection_exists?(connections, "linkedin"),
        linkedin_email:     connection_email(connections, "linkedin"),
      }
    end

    private def connection_exists?(connections : Array(SocialConnection), provider : String) : Bool
      !connections.find { |connection| connection.provider == provider }.nil?
    end

    private def connection_email(connections : Array(SocialConnection), provider : String) : String
      connections.find { |connection| connection.provider == provider }.try(&.email) || ""
    end
  end
end
