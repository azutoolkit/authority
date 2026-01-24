# Endpoint for Admin Clients CSV Export
# GET /dashboard/clients/export - Export all clients to CSV
module Authority::Dashboard::Clients
  class ExportEndpoint
    include SessionHelper
    include SecurityHeadersHelper
    include AdminAuthHelper
    include Endpoint(IndexRequest, Response)

    get "/dashboard/clients/export"

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
      options = AdminClientService::ListOptions.new(
        page: 1,
        per_page: Int32::MAX,
        search: index_request.search.empty? ? nil : index_request.search,
        confidentiality: index_request.confidentiality.empty? ? nil : index_request.confidentiality,
        scope: index_request.scope.empty? ? nil : index_request.scope
      )

      # Export clients
      result = ExportService.export_clients(options)

      if result.success?
        header "Content-Type", "text/csv; charset=UTF-8"
        header "Content-Disposition", "attachment; filename=\"#{result.filename}\""
        CsvResponse.new(result.content.not_nil!)
      else
        redirect to: "/dashboard/clients?error=Export+failed", status: 302
      end
    end
  end
end
