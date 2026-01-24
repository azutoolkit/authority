# Response for User Profile page
module Authority::Profile
  struct ConnectedApp
    property name : String
    property logo : String
    property client_id : String
    property connected_at : String

    def initialize(@name, @logo, @client_id, @connected_at)
    end
  end

  struct ProfileResponse
    include Response
    include Templates::Renderable

    TEMPLATE = "auth/profile/user_profile.html"

    def initialize(
      @first_name : String,
      @last_name : String,
      @email : String,
      @username : String,
      @email_verified : Bool = false,
      @mfa_enabled : Bool = false,
      @created_at : String = "",
      @last_login : String = "",
      @connected_apps : Array(ConnectedApp) = [] of ConnectedApp,
      @errors : Array(String)? = nil,
      @forward_url : String = "/profile",
      # Social provider enabled flags
      @social_providers_enabled : Bool = false,
      @google_enabled : Bool = false,
      @github_enabled : Bool = false,
      @facebook_enabled : Bool = false,
      @apple_enabled : Bool = false,
      @linkedin_enabled : Bool = false,
      # Social connection status
      @google_connected : Bool = false,
      @google_email : String = "",
      @github_connected : Bool = false,
      @github_email : String = "",
      @facebook_connected : Bool = false,
      @facebook_email : String = "",
      @apple_connected : Bool = false,
      @apple_email : String = "",
      @linkedin_connected : Bool = false,
      @linkedin_email : String = ""
    )
    end

    def render
      view TEMPLATE, {
        first_name:               @first_name,
        last_name:                @last_name,
        email:                    @email,
        username:                 @username,
        email_verified:           @email_verified,
        mfa_enabled:              @mfa_enabled,
        created_at:               @created_at,
        last_login:               @last_login,
        connected_apps:           @connected_apps.map { |app|
          {
            name:         app.name,
            logo:         app.logo,
            client_id:    app.client_id,
            connected_at: app.connected_at,
          }
        },
        errors:                   @errors,
        forward_url:              Base64.urlsafe_encode(@forward_url),
        social_providers_enabled: @social_providers_enabled,
        google_enabled:           @google_enabled,
        github_enabled:           @github_enabled,
        facebook_enabled:         @facebook_enabled,
        apple_enabled:            @apple_enabled,
        linkedin_enabled:         @linkedin_enabled,
        google_connected:         @google_connected,
        google_email:             @google_email,
        github_connected:         @github_connected,
        github_email:             @github_email,
        facebook_connected:       @facebook_connected,
        facebook_email:           @facebook_email,
        apple_connected:          @apple_connected,
        apple_email:              @apple_email,
        linkedin_connected:       @linkedin_connected,
        linkedin_email:           @linkedin_email,
      }
    end
  end
end
