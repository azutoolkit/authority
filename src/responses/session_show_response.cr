# Response Docs https://azutopia.gitbook.io/azu/endpoints/response
module Authority
  struct SessionShowResponse
    include Response
    include Templates::Renderable

    TEMPLATE = "login_form.html"

    def initialize(@forward_url : String = "/user-info", @errors : Array(String)? = nil)
    end

    def render
      render TEMPLATE, {
        forward_url: @forward_url, errors: @errors,
      }
    end
  end
end
