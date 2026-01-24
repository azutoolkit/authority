# Response Docs https://azutopia.gitbook.io/azu/endpoints/response
module Authority::Sessions
  struct FormResponse
    include Response
    include Templates::Renderable

    TEMPLATE = "auth/sessions/new_session_form.jinja"

    def initialize(@forward_url : String = SIGNIN_PATH, @errors : Array(String)? = nil)
    end

    def render
      view TEMPLATE, {
        forward_url: @forward_url, errors: @errors,
      }
    end
  end
end
