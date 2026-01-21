# Response for Admin Scope New page
module Authority::Dashboard::Scopes
  struct NewResponse
    include Response
    include Templates::Renderable

    TEMPLATE = "admin/scopes/new.html"

    def initialize(
      @username : String = "",
      @errors : Array(String)? = nil,
      # Form values for re-display on error
      @name : String = "",
      @display_name : String = "",
      @description : String = "",
      @is_default : Bool = false
    )
    end

    def render
      view TEMPLATE, {
        username:     @username,
        errors:       @errors,
        name:         @name,
        display_name: @display_name,
        description:  @description,
        is_default:   @is_default,
      }
    end
  end
end
