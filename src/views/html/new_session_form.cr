# Response Docs https://azutopia.gitbook.io/azu/endpoints/response
module Authority::Sessions
  struct NewSessionForm
    include Response
    include Templates::Renderable

    def initialize(@forward_url : String, @errors : Array(String)? = nil)
    end

    def render
      view data: {
        session:     {} of String => String,
        forward_url: @forward_url,
        errors:      @errors,
      }
    end
  end
end
