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
      header "Content-Type", "text/html; charset=UTF-8"
      header "Cache-Control", "no-store"
      header "Pragma", "no-cache"

      # Check if user is authenticated
      return redirect_to_signin unless authenticated?

      # Get the current user
      user = OwnerRepo.find_by_id(current_session.user_id)
      return redirect_to_signin unless user

      # Get connected applications (grants)
      connected_apps = [] of ConnectedApp
      # Note: This would need to be implemented based on your grants/consents storage
      # grants = UserGrant.find_by_user(session.user_id)
      # connected_apps = grants.map { |g| ConnectedApp.new(g.client.name, g.client.logo, g.client_id, g.created_at.to_s) }

      # Get social provider status
      google_enabled = SocialOAuthService.provider_enabled?("google")
      github_enabled = SocialOAuthService.provider_enabled?("github")
      facebook_enabled = SocialOAuthService.provider_enabled?("facebook")
      apple_enabled = SocialOAuthService.provider_enabled?("apple")
      linkedin_enabled = SocialOAuthService.provider_enabled?("linkedin")

      social_providers_enabled = google_enabled || github_enabled || facebook_enabled || apple_enabled || linkedin_enabled

      # Get user's social connections
      user_id = user.id
      social_connections = user_id ? SocialConnection.find_by_user(user_id) : [] of SocialConnection

      google_connection = social_connections.find { |c| c.provider == "google" }
      github_connection = social_connections.find { |c| c.provider == "github" }
      facebook_connection = social_connections.find { |c| c.provider == "facebook" }
      apple_connection = social_connections.find { |c| c.provider == "apple" }
      linkedin_connection = social_connections.find { |c| c.provider == "linkedin" }

      ProfileResponse.new(
        first_name: user.first_name,
        last_name: user.last_name,
        email: user.email,
        username: user.username,
        email_verified: user.email_verified,
        mfa_enabled: user.mfa_enabled,
        created_at: user.created_at.try(&.to_s("%B %d, %Y")) || "",
        last_login: user.updated_at.try(&.to_s("%B %d, %Y %H:%M")) || "",
        connected_apps: connected_apps,
        forward_url: "/profile",
        social_providers_enabled: social_providers_enabled,
        google_enabled: google_enabled,
        github_enabled: github_enabled,
        facebook_enabled: facebook_enabled,
        apple_enabled: apple_enabled,
        linkedin_enabled: linkedin_enabled,
        google_connected: !google_connection.nil?,
        google_email: google_connection.try(&.email) || "",
        github_connected: !github_connection.nil?,
        github_email: github_connection.try(&.email) || "",
        facebook_connected: !facebook_connection.nil?,
        facebook_email: facebook_connection.try(&.email) || "",
        apple_connected: !apple_connection.nil?,
        apple_email: apple_connection.try(&.email) || "",
        linkedin_connected: !linkedin_connection.nil?,
        linkedin_email: linkedin_connection.try(&.email) || ""
      )
    end
  end
end
