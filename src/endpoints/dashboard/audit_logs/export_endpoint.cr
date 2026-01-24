# Endpoint for Admin Audit Logs CSV Export
# GET /dashboard/audit-logs/export - Export audit logs to CSV
module Authority::Dashboard::AuditLogs
  class ExportEndpoint
    include SessionHelper
    include SecurityHeadersHelper
    include AdminAuthHelper
    include Endpoint(IndexRequest, Response)

    get "/dashboard/audit-logs/export"

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

      # Parse date filters
      start_date : Time? = nil
      end_date : Time? = nil

      if sd = index_request.start_date
        if !sd.empty?
          begin
            start_date = Time.parse(sd, "%Y-%m-%d", Time::Location::UTC)
          rescue
            # Invalid date format, ignore
          end
        end
      end

      if ed = index_request.end_date
        if !ed.empty?
          begin
            parsed = Time.parse(ed, "%Y-%m-%d", Time::Location::UTC)
            end_date = parsed + 1.day - 1.second
          rescue
            # Invalid date format, ignore
          end
        end
      end

      # Export audit logs
      action_filter = index_request.action
      action_filter = nil if action_filter.try(&.empty?)

      resource_type_filter = index_request.resource_type
      resource_type_filter = nil if resource_type_filter.try(&.empty?)

      actor_id_filter = index_request.actor_id
      actor_id_filter = nil if actor_id_filter.try(&.empty?)

      result = ExportService.export_audit_logs(
        start_date: start_date,
        end_date: end_date,
        action: action_filter,
        resource_type: resource_type_filter,
        actor_id: actor_id_filter
      )

      if result.success?
        header "Content-Type", "text/csv; charset=UTF-8"
        header "Content-Disposition", "attachment; filename=\"#{result.filename}\""
        CsvResponse.new(result.content.not_nil!)
      else
        redirect to: "/dashboard/audit-logs?error=Export+failed", status: 302
      end
    end
  end
end
