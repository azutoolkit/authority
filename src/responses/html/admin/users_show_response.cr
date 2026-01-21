# Response for Admin User Show page
module Authority::Dashboard::Users
  struct ShowResponse
    include Response
    include Templates::Renderable

    TEMPLATE = "admin/users/show.html"

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
