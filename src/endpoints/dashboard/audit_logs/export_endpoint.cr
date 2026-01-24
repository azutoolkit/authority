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

      if auth_error = require_admin!
        return auth_error
      end

      admin_user = current_admin_user
      return forbidden_response("Admin access required") unless admin_user

      result = export_audit_logs
      build_export_response(result)
    end

    private def export_audit_logs
      ExportService.export_audit_logs(
        start_date: parse_start_date,
        end_date: parse_end_date,
        action: filter_empty(index_request.action),
        resource_type: filter_empty(index_request.resource_type),
        actor_id: filter_empty(index_request.actor_id)
      )
    end

    private def parse_start_date : Time?
      parse_date(index_request.start_date)
    end

    private def parse_end_date : Time?
      date_str = index_request.end_date
      return nil if date_str.nil? || date_str.empty?

      parsed = parse_date(date_str)
      parsed.try { |date| date + 1.day - 1.second }
    end

    private def parse_date(date_str : String?) : Time?
      return nil if date_str.nil? || date_str.empty?
      Time.parse(date_str, "%Y-%m-%d", Time::Location::UTC)
    rescue
      nil
    end

    private def filter_empty(value : String?) : String?
      return nil if value.nil? || value.empty?
      value
    end

    private def build_export_response(result) : Response
      if result.success? && (content = result.content)
        header "Content-Type", "text/csv; charset=UTF-8"
        header "Content-Disposition", "attachment; filename=\"#{result.filename}\""
        CsvResponse.new(content)
      else
        redirect to: "/dashboard/audit-logs?error=Export+failed", status: 302
      end
    end
  end
end
