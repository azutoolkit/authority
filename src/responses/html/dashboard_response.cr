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
      @stats : AnalyticsService::DashboardStats? = nil,
      @login_activity : Array(AnalyticsService::LoginActivity)? = nil,
      @recent_activity : Array(AnalyticsService::RecentActivity)? = nil,
      @errors : Array(String)? = nil
    )
    end

    def render
      view TEMPLATE, {
        username:        @username,
        email:           @email,
        clients_count:   @clients_count,
        stats:           @stats,
        login_activity:  @login_activity,
        recent_activity: @recent_activity,
        errors:          @errors,
      }
    end
  end
end
