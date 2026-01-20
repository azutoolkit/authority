# HTML Error Response
# Renders the error.html template for displaying error pages
module Authority
  struct ErrorResponse
    include Response
    include Templates::Renderable

    TEMPLATE = "error.html"

    def initialize(
      @status : Int32,
      @title : String,
      @detail : String? = nil,
      @source : String? = nil,
      @errors : Array(String)? = nil
    )
    end

    def render
      view TEMPLATE, {
        status: @status,
        title:  @title,
        detail: @detail,
        source: @source,
        errors: @errors,
      }
    end
  end
end
