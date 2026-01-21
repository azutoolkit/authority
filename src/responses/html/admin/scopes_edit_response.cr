# Response for Admin Scope Edit page
module Authority::Dashboard::Scopes
  struct EditResponse
    include Response
    include Templates::Renderable

    TEMPLATE = "admin/scopes/edit.html"

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
