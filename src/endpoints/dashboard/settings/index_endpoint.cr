# Endpoint for Admin Settings Index page
# GET /dashboard/settings - Display system settings
module Authority::Dashboard::Settings
  class IndexEndpoint
    include SessionHelper
    include SecurityHeadersHelper
    include AdminAuthHelper
    include Endpoint(IndexRequest, IndexResponse | Response)

    get "/dashboard/settings"

    def call : IndexResponse | Response
      set_security_headers!
      header "Content-Type", "text/html; charset=UTF-8"
      header "Cache-Control", "no-store"
      header "Pragma", "no-cache"

      # Check admin authorization
      if auth_error = require_admin!
        return auth_error
      end

      admin_user = current_admin_user
      return forbidden_response("Admin access required") unless admin_user

      # Check for super_admin scope for sensitive settings
      unless RBACService.has_scope?(admin_user, "authority:super_admin")
        return forbidden_response("Super admin access required for settings")
      end

      # Get all settings grouped by category
      settings = SettingsService.get_all_grouped

      IndexResponse.new(
        settings: settings,
        active_tab: index_request.tab,
        username: admin_user.username
      )
    end
  end
end
