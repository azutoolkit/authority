# Response for Admin Scope Show page
module Authority::Dashboard::Scopes
  struct ShowResponse
    include Response
    include Templates::Renderable

    TEMPLATE = "admin/scopes/show.html"

    def initialize(
      @scope : Scope,
      @username : String = "",
      @errors : Array(String)? = nil
    )
    end

    def render
      view TEMPLATE, {
        scope:    @scope,
        username: @username,
        errors:   @errors,
      }
    end
  end
end
