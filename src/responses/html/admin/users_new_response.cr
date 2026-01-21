# Response for Admin User New page
module Authority::Dashboard::Users
  struct NewResponse
    include Response
    include Templates::Renderable

    TEMPLATE = "admin/users/new.html"

    def initialize(
      @username : String = "",
      @errors : Array(String)? = nil,
      # Form values for re-display on error
      @form_username : String = "",
      @email : String = "",
      @first_name : String = "",
      @last_name : String = "",
      @role : String = "user",
      @scope : String = "",
      @email_verified : Bool = false
    )
    end

    def render
      view TEMPLATE, {
        username:       @username,
        errors:         @errors,
        form_username:  @form_username,
        email:          @email,
        first_name:     @first_name,
        last_name:      @last_name,
        role:           @role,
        scope:          @scope,
        email_verified: @email_verified,
      }
    end
  end
end
