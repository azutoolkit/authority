# Endpoint for Admin Users CSV Export
# GET /dashboard/users/export - Export all users to CSV
module Authority::Dashboard::Users
  class ExportEndpoint
    include SessionHelper
    include SecurityHeadersHelper
    include AdminAuthHelper
    include Endpoint(IndexRequest, Response)

    get "/dashboard/users/export"

    def call : Response
      set_security_headers!
      header "Cache-Control", "no-store"
      header "Pragma", "no-cache"

      # Check admin authorization
      if auth_error = require_admin!
        return auth_error
      end

      admin_user = current_admin_user
      return forbidden_response("Admin access required") unless admin_user

      # Build options from filter params (same as index)
      options = AdminUserService::ListOptions.new(
        page: 1,
        per_page: Int32::MAX,
        search: index_request.search.empty? ? nil : index_request.search,
        status: index_request.status.empty? ? nil : index_request.status,
        role: index_request.role.empty? ? nil : index_request.role
      )

      # Export users
      result = ExportService.export_users(options)

      if result.success?
        header "Content-Type", "text/csv; charset=UTF-8"
        header "Content-Disposition", "attachment; filename=\"#{result.filename}\""
        CsvResponse.new(result.content.not_nil!)
      else
        redirect to: "/dashboard/users?error=Export+failed", status: 302
      end
    end
  end
end
