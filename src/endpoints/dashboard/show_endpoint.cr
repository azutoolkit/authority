# Endpoint for Dashboard page
# GET /dashboard - Display the user dashboard
module Authority::Dashboard
  class ShowEndpoint
    include SessionHelper
    include SecurityHeadersHelper
    include Endpoint(ShowRequest, DashboardResponse | Response)

    get "/dashboard"

    def call : DashboardResponse | Response
      set_security_headers!
      header "Content-Type", "text/html; charset=UTF-8"
      header "Cache-Control", "no-store"
      header "Pragma", "no-cache"

      # Check if user is authenticated
      return redirect_to_signin unless authenticated?

      # Get the current user
      user = OwnerRepo.find_by_id(current_session.user_id)
      return redirect_to_signin unless user

      # Get clients count (if user has any registered clients)
      clients_count = Client.query.count.to_i32

      # Get analytics data
      stats = AnalyticsService.dashboard_stats
      login_activity = AnalyticsService.login_activity(7)
      recent_activity = AnalyticsService.recent_activity(5)

      DashboardResponse.new(
        username: user.username,
        email: user.email,
        clients_count: clients_count,
        stats: stats,
        login_activity: login_activity,
        recent_activity: recent_activity
      )
    end
  end
end
