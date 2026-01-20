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

    TEMPLATE = "user_profile.html"

    def initialize(
      @first_name : String,
      @last_name : String,
      @email : String,
      @username : String,
      @email_verified : Bool = false,
      @created_at : String = "",
      @last_login : String = "",
      @connected_apps : Array(ConnectedApp) = [] of ConnectedApp,
      @errors : Array(String)? = nil
    )
    end

    def render
      view TEMPLATE, {
        first_name:     @first_name,
        last_name:      @last_name,
        email:          @email,
        username:       @username,
        email_verified: @email_verified,
        created_at:     @created_at,
        last_login:     @last_login,
        connected_apps: @connected_apps.map { |app|
          {
            name:         app.name,
            logo:         app.logo,
            client_id:    app.client_id,
            connected_at: app.connected_at,
          }
        },
        errors: @errors,
      }
    end
  end
end
