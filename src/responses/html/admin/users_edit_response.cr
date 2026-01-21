# Response for Admin User Edit page
module Authority::Dashboard::Users
  struct EditResponse
    include Response
    include Templates::Renderable

    TEMPLATE = "admin/users/edit.html"

    def initialize(
      @user : User,
      @username : String = "",
      @errors : Array(String)? = nil
    )
    end

    def render
      view TEMPLATE, {
        user:     @user,
        username: @username,
        errors:   @errors,
      }
    end
  end
end
