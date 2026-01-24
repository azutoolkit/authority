# Export Service
# Provides CSV export functionality for admin data.
module Authority
  module ExportService
    extend self

    # Result struct for export operations
    struct ExportResult
      getter? success : Bool
      getter content : String?
      getter filename : String?
      getter error : String?

      def initialize(
        @success : Bool,
        @content : String? = nil,
        @filename : String? = nil,
        @error : String? = nil
      )
      end
    end

    # Export users to CSV
    def export_users(options : AdminUserService::ListOptions = AdminUserService::ListOptions.new) : ExportResult
      # Fetch all users matching the filter (no pagination limit)
      all_options = AdminUserService::ListOptions.new(
        page: 1,
        per_page: Int32::MAX,
        search: options.search,
        status: options.status,
        role: options.role,
        sort_by: options.sort_by,
        sort_dir: options.sort_dir
      )
      users = AdminUserService.list(all_options)

      csv = String.build do |io|
        # Header row
        io << "ID,Username,Email,First Name,Last Name,Role,Status,Email Verified,MFA Enabled,Last Login,Created At\n"

        # Data rows
        users.each do |user|
          io << csv_escape(user.id.to_s) << ","
          io << csv_escape(user.username) << ","
          io << csv_escape(user.email) << ","
          io << csv_escape(user.first_name) << ","
          io << csv_escape(user.last_name) << ","
          io << csv_escape(user.role) << ","
          io << csv_escape(user.locked? ? "Locked" : "Active") << ","
          io << csv_escape(user.email_verified?.to_s) << ","
          io << csv_escape(user.mfa_enabled?.to_s) << ","
          io << csv_escape(user.last_login_at.try(&.to_s("%Y-%m-%d %H:%M:%S")) || "") << ","
          io << csv_escape(user.created_at.try(&.to_s("%Y-%m-%d %H:%M:%S")) || "") << "\n"
        end
      end

      timestamp = Time.utc.to_s("%Y%m%d_%H%M%S")
      ExportResult.new(
        success: true,
        content: csv,
        filename: "users_export_#{timestamp}.csv"
      )
    rescue e
      ExportResult.new(success: false, error: e.message)
    end

    # Export specific users by IDs
    def export_users_by_ids(ids : Array(String)) : ExportResult
      users = ids.compact_map { |id| AdminUserService.get(id) }

      csv = String.build do |io|
        # Header row
        io << "ID,Username,Email,First Name,Last Name,Role,Status,Email Verified,MFA Enabled,Last Login,Created At\n"

        # Data rows
        users.each do |user|
          io << csv_escape(user.id.to_s) << ","
          io << csv_escape(user.username) << ","
          io << csv_escape(user.email) << ","
          io << csv_escape(user.first_name) << ","
          io << csv_escape(user.last_name) << ","
          io << csv_escape(user.role) << ","
          io << csv_escape(user.locked? ? "Locked" : "Active") << ","
          io << csv_escape(user.email_verified?.to_s) << ","
          io << csv_escape(user.mfa_enabled?.to_s) << ","
          io << csv_escape(user.last_login_at.try(&.to_s("%Y-%m-%d %H:%M:%S")) || "") << ","
          io << csv_escape(user.created_at.try(&.to_s("%Y-%m-%d %H:%M:%S")) || "") << "\n"
        end
      end

      timestamp = Time.utc.to_s("%Y%m%d_%H%M%S")
      ExportResult.new(
        success: true,
        content: csv,
        filename: "users_export_#{timestamp}.csv"
      )
    rescue e
      ExportResult.new(success: false, error: e.message)
    end

    # Export clients to CSV
    def export_clients(options : AdminClientService::ListOptions = AdminClientService::ListOptions.new) : ExportResult
      # Fetch all clients matching the filter (no pagination limit)
      all_options = AdminClientService::ListOptions.new(
        page: 1,
        per_page: Int32::MAX,
        search: options.search,
        confidentiality: options.confidentiality,
        scope: options.scope,
        sort_by: options.sort_by,
        sort_dir: options.sort_dir
      )
      clients = AdminClientService.list(all_options)

      csv = String.build do |io|
        # Header row
        io << "ID,Client ID,Name,Description,Redirect URI,Scopes,Confidential,Created At\n"

        # Data rows
        clients.each do |client|
          io << csv_escape(client.id.to_s) << ","
          io << csv_escape(client.client_id) << ","
          io << csv_escape(client.name) << ","
          io << csv_escape(client.description || "") << ","
          io << csv_escape(client.redirect_uri) << ","
          io << csv_escape(client.scopes) << ","
          io << csv_escape(client.is_confidential?.to_s) << ","
          io << csv_escape(client.created_at.try(&.to_s("%Y-%m-%d %H:%M:%S")) || "") << "\n"
        end
      end

      timestamp = Time.utc.to_s("%Y%m%d_%H%M%S")
      ExportResult.new(
        success: true,
        content: csv,
        filename: "clients_export_#{timestamp}.csv"
      )
    rescue e
      ExportResult.new(success: false, error: e.message)
    end

    # Export specific clients by IDs
    def export_clients_by_ids(ids : Array(String)) : ExportResult
      clients = ids.compact_map { |id| AdminClientService.get(id) }

      csv = String.build do |io|
        # Header row
        io << "ID,Client ID,Name,Description,Redirect URI,Scopes,Confidential,Created At\n"

        # Data rows
        clients.each do |client|
          io << csv_escape(client.id.to_s) << ","
          io << csv_escape(client.client_id) << ","
          io << csv_escape(client.name) << ","
          io << csv_escape(client.description || "") << ","
          io << csv_escape(client.redirect_uri) << ","
          io << csv_escape(client.scopes) << ","
          io << csv_escape(client.is_confidential?.to_s) << ","
          io << csv_escape(client.created_at.try(&.to_s("%Y-%m-%d %H:%M:%S")) || "") << "\n"
        end
      end

      timestamp = Time.utc.to_s("%Y%m%d_%H%M%S")
      ExportResult.new(
        success: true,
        content: csv,
        filename: "clients_export_#{timestamp}.csv"
      )
    rescue e
      ExportResult.new(success: false, error: e.message)
    end

    # Export audit logs to CSV
    def export_audit_logs(
      start_date : Time? = nil,
      end_date : Time? = nil,
      action : String? = nil,
      resource_type : String? = nil,
      actor_id : String? = nil,
      limit : Int32 = 10000
    ) : ExportResult
      logs = fetch_filtered_audit_logs(
        start_date: start_date,
        end_date: end_date,
        action: action,
        resource_type: resource_type,
        actor_id: actor_id,
        limit: limit
      )

      csv = String.build do |io|
        io << audit_log_csv_header
        logs.each { |log| io << format_audit_log_row(log) }
      end

      timestamp = Time.utc.to_s("%Y%m%d_%H%M%S")
      ExportResult.new(
        success: true,
        content: csv,
        filename: "audit_logs_export_#{timestamp}.csv"
      )
    rescue e
      ExportResult.new(success: false, error: e.message)
    end

    # Fetch audit logs with database and in-memory filters applied
    private def fetch_filtered_audit_logs(
      start_date : Time?,
      end_date : Time?,
      action : String?,
      resource_type : String?,
      actor_id : String?,
      limit : Int32
    ) : Array(AuditLog)
      query = build_audit_log_query(action, resource_type)
      logs = query.limit(limit).all
      apply_audit_log_memory_filters(logs, start_date, end_date, actor_id)
    end

    # Build the database query with filters that can be applied at DB level
    private def build_audit_log_query(action : String?, resource_type : String?)
      query = AuditLog.query.order(created_at: :desc)
      query = query.where(action: action) if action && !action.empty?
      query = query.where(resource_type: resource_type) if resource_type && !resource_type.empty?
      query
    end

    # Apply filters that must be done in memory
    private def apply_audit_log_memory_filters(
      logs : Array(AuditLog),
      start_date : Time?,
      end_date : Time?,
      actor_id : String?
    ) : Array(AuditLog)
      result = logs
      result = result.select { |log| (cat = log.created_at) && cat >= start_date } if start_date
      result = result.select { |log| (cat = log.created_at) && cat <= end_date } if end_date
      result = result.select { |log| log.actor_id.try(&.to_s) == actor_id } if actor_id && !actor_id.empty?
      result
    end

    # Generate CSV header for audit logs
    private def audit_log_csv_header : String
      "ID,Timestamp,Actor Email,Action,Resource Type,Resource ID,Resource Name,IP Address,User Agent,Changes\n"
    end

    # Format a single audit log entry as a CSV row
    private def format_audit_log_row(log : AuditLog) : String
      String.build do |io|
        io << csv_escape(log.id.to_s) << ","
        io << csv_escape(log.created_at.try(&.to_s("%Y-%m-%d %H:%M:%S")) || "") << ","
        io << csv_escape(log.actor_email.empty? ? "System" : log.actor_email) << ","
        io << csv_escape(log.action) << ","
        io << csv_escape(log.resource_type) << ","
        io << csv_escape(log.resource_id.try(&.to_s) || "") << ","
        io << csv_escape(log.resource_name || "") << ","
        io << csv_escape(log.ip_address || "") << ","
        io << csv_escape(log.user_agent || "") << ","
        io << csv_escape(log.changes || "") << "\n"
      end
    end

    # Escape CSV field values
    private def csv_escape(value : String) : String
      if value.includes?(",") || value.includes?("\"") || value.includes?("\n")
        "\"#{value.gsub("\"", "\"\"")}\""
      else
        value
      end
    end
  end
end
