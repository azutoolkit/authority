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
      user = User.find!(current_session.user_id)

      # Get clients count (if user has any registered clients)
      clients_count = Client.query.count.to_i32

      DashboardResponse.new(
        username: user.username,
        email: user.email,
        clients_count: clients_count
      )
    end
  end
end
