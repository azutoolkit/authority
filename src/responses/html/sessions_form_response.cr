# Response Docs https://azutopia.gitbook.io/azu/endpoints/response
module Authority::Sessions
  struct FormResponse
    include Response
    include Templates::Renderable

    TEMPLATE = "auth/sessions/new_session_form.jinja"

    def initialize(
      @forward_url : String = SIGNIN_PATH,
      @errors : Array(String)? = nil,
      @google_enabled : Bool = false,
      @github_enabled : Bool = false,
      @facebook_enabled : Bool = false,
      @apple_enabled : Bool = false,
      @linkedin_enabled : Bool = false
    )
    end

    def render
      view TEMPLATE, {
        forward_url:      @forward_url,
        errors:           @errors,
        google_enabled:   @google_enabled,
        github_enabled:   @github_enabled,
        facebook_enabled: @facebook_enabled,
        apple_enabled:    @apple_enabled,
        linkedin_enabled: @linkedin_enabled,
      }
    end
  end
end
