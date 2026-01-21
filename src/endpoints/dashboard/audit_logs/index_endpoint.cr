# Endpoint for Admin Audit Logs List page
# GET /dashboard/audit-logs - Display list of audit log entries
module Authority::Dashboard::AuditLogs
  class IndexEndpoint
    include SessionHelper
    include SecurityHeadersHelper
    include AdminAuthHelper
    include Endpoint(IndexRequest, IndexResponse | Response)

    get "/dashboard/audit-logs"

    def call : IndexResponse | Response
      set_security_headers!
      header "Content-Type", "text/html; charset=UTF-8"
      header "Cache-Control", "no-store"
      header "Pragma", "no-cache"

      # Check admin authorization
      if auth_error = require_admin!
        return auth_error
      end

      user = current_admin_user
      return forbidden_response("Admin access required") unless user

      # Get pagination and filter params
      page = index_request.page > 0 ? index_request.page : 1
      per_page = 20

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
            # Set end date to end of day
            parsed = Time.parse(ed, "%Y-%m-%d", Time::Location::UTC)
            end_date = parsed + 1.day - 1.second
          rescue
            # Invalid date format, ignore
          end
        end
      end

      # Build list options
      options = AuditService::ListOptions.new(
        page: page,
        per_page: per_page,
        actor_id: index_request.actor_id,
        action: index_request.action,
        resource_type: index_request.resource_type,
        start_date: start_date,
        end_date: end_date
      )

      # Fetch audit logs
      logs = AuditService.list(options)
      total_count = AuditService.count(options)

      # Get filter options for dropdowns
      actors = AuditService.distinct_actors
      actions = AuditService.distinct_actions

      IndexResponse.new(
        logs: logs,
        page: page,
        per_page: per_page,
        total_count: total_count,
        actors: actors,
        actions: actions,
        filter_actor_id: index_request.actor_id,
        filter_action: index_request.action,
        filter_resource_type: index_request.resource_type,
        filter_start_date: index_request.start_date,
        filter_end_date: index_request.end_date,
        username: user.username
      )
    end
  end
end
