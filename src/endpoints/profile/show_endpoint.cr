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
      user = User.find!(current_session.user_id)

      # Get connected applications (grants)
      connected_apps = [] of ConnectedApp
      # Note: This would need to be implemented based on your grants/consents storage
      # grants = UserGrant.find_by_user(session.user_id)
      # connected_apps = grants.map { |g| ConnectedApp.new(g.client.name, g.client.logo, g.client_id, g.created_at.to_s) }

      ProfileResponse.new(
        first_name: user.first_name,
        last_name: user.last_name,
        email: user.email,
        username: user.username,
        email_verified: user.email_verified,
        created_at: user.created_at.try(&.to_s("%B %d, %Y")) || "",
        last_login: user.updated_at.try(&.to_s("%B %d, %Y %H:%M")) || "",
        connected_apps: connected_apps
      )
    end
  end
end
