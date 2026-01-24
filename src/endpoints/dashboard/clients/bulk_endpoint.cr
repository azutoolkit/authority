# Endpoint for Admin Client Bulk Operations
# POST /dashboard/clients/bulk - Perform bulk operations on clients
module Authority::Dashboard::Clients
  class BulkEndpoint
    include SessionHelper
    include SecurityHeadersHelper
    include AdminAuthHelper
    include Endpoint(BulkRequest, Response)

    post "/dashboard/clients/bulk"

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

      ids = bulk_request.ids
      action = bulk_request.action

      # Validate request
      if ids.empty?
        return redirect_with_error("No clients selected")
      end

      case action
      when "delete"
        result = AdminClientService.bulk_delete(ids, admin_user)
        if result.success?
          redirect to: "/dashboard/clients?success=Deleted+#{result.succeeded}+clients", status: 302
        else
          redirect to: "/dashboard/clients?error=Deleted+#{result.succeeded}+clients,+failed+#{result.failed}", status: 302
        end

      when "export"
        export_result = ExportService.export_clients_by_ids(ids)
        if export_result.success?
          header "Content-Type", "text/csv; charset=UTF-8"
          header "Content-Disposition", "attachment; filename=\"#{export_result.filename}\""
          text export_result.content.not_nil!
        else
          redirect_with_error("Export failed: #{export_result.error}")
        end

      else
        redirect_with_error("Unknown action: #{action}")
      end
    end

    private def redirect_with_error(message : String) : Response
      redirect to: "/dashboard/clients?error=#{URI.encode_path(message)}", status: 302
    end
  end
end
