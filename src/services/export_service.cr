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
          io << csv_escape(user.email_verified.to_s) << ","
          io << csv_escape(user.mfa_enabled.to_s) << ","
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
          io << csv_escape(user.email_verified.to_s) << ","
          io << csv_escape(user.mfa_enabled.to_s) << ","
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
      query = AuditLog.query.order(created_at: :desc)

      # Apply filters at DB level where possible
      if action && !action.empty?
        query = query.where(action: action)
      end

      if resource_type && !resource_type.empty?
        query = query.where(resource_type: resource_type)
      end

      # Fetch logs
      logs = query.limit(limit).all

      # Apply date filters in memory
      if sd = start_date
        logs = logs.select { |log| (cat = log.created_at) && cat >= sd }
      end

      if ed = end_date
        logs = logs.select { |log| (cat = log.created_at) && cat <= ed }
      end

      # Apply actor filter in memory
      if actor_id && !actor_id.empty?
        logs = logs.select { |log| log.actor_id.try(&.to_s) == actor_id }
      end

      csv = String.build do |io|
        # Header row
        io << "ID,Timestamp,Actor Email,Action,Resource Type,Resource ID,Resource Name,IP Address,User Agent,Changes\n"

        # Data rows
        logs.each do |log|
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

      timestamp = Time.utc.to_s("%Y%m%d_%H%M%S")
      ExportResult.new(
        success: true,
        content: csv,
        filename: "audit_logs_export_#{timestamp}.csv"
      )
    rescue e
      ExportResult.new(success: false, error: e.message)
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
