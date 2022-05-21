# Response Docs https://azutopia.gitbook.io/azu/endpoints/response
module Authority::Sessions
  struct FormResponse
    include Response
    include Templates::Renderable

    TEMPLATE = "new_session_form.html"

    def initialize(@forward_url : String = SIGNIN_PATH, @errors : Array(String)? = nil)
    end

    def render
      render TEMPLATE, {
        forward_url: @forward_url, errors: @errors,
      }
    end
  end
end
