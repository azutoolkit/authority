# Response for Dashboard page
module Authority::Dashboard
  struct DashboardResponse
    include Response
    include Templates::Renderable

    TEMPLATE = "dashboard.html"

    def initialize(
      @username : String,
      @email : String,
      @clients_count : Int32 = 0,
      @errors : Array(String)? = nil
    )
    end

    def render
      view TEMPLATE, {
        username:      @username,
        email:         @email,
        clients_count: @clients_count,
        errors:        @errors,
      }
    end
  end
end
