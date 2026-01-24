# Audit Retention Service
# Provides cleanup and retention management for audit logs.
module Authority
  class AuditRetentionService
    # Result struct for service operations
    struct Result
      getter? success : Bool
      getter deleted_count : Int32
      getter archived_count : Int32
      getter error : String?

      def initialize(
        @success : Bool,
        @deleted_count : Int32 = 0,
        @archived_count : Int32 = 0,
        @error : String? = nil
      )
      end
    end

    # Get retention days from settings (default 365)
    def self.retention_days : Int32
      SettingsService.get_int(Setting::Keys::AUDIT_RETENTION_DAYS, 365)
    end

    # Clean up audit logs older than retention period
    def self.cleanup : Result
      retention = retention_days
      cutoff_date = Time.utc - retention.days
      deleted_count = 0

      # Get logs older than retention period
      old_logs = AuditLog.query
        .order(created_at: :asc)
        .all
        .select { |log| (cat = log.created_at) && cat < cutoff_date }

      # Delete old logs
      old_logs.each do |log|
        log.delete!
        deleted_count += 1
      end

      Log.info { "Audit retention cleanup: deleted #{deleted_count} logs older than #{retention} days" }

      Result.new(success: true, deleted_count: deleted_count)
    rescue e
      Result.new(success: false, error: e.message)
    end

    # Get statistics about audit log retention
    def self.statistics : Hash(String, Int64 | String)
      total = AuditLog.query.count.to_i64
      cutoff_date = Time.utc - retention_days.days

      # Count logs that would be deleted
      logs_to_delete = AuditLog.query
        .all
        .count { |log| (cat = log.created_at) && cat < cutoff_date }
        .to_i64

      oldest = AuditLog.query.order(created_at: :asc).first
      newest = AuditLog.query.order(created_at: :desc).first

      {
        "total_logs"      => total,
        "logs_to_delete"  => logs_to_delete,
        "retention_days"  => retention_days.to_i64,
        "oldest_log_date" => oldest.try(&.created_at.try(&.to_s("%Y-%m-%d"))) || "N/A",
        "newest_log_date" => newest.try(&.created_at.try(&.to_s("%Y-%m-%d"))) || "N/A",
      }
    rescue
      {
        "total_logs"      => 0_i64,
        "logs_to_delete"  => 0_i64,
        "retention_days"  => retention_days.to_i64,
        "oldest_log_date" => "N/A",
        "newest_log_date" => "N/A",
      }
    end

    # Archive old logs before deletion (optional - can be used to export before cleanup)
    def self.archive_and_cleanup(archive_path : String? = nil) : Result
      retention = retention_days
      cutoff_date = Time.utc - retention.days
      archived_count = 0
      deleted_count = 0

      # If archive path is provided, export old logs first
      if archive_path
        export_result = ExportService.export_audit_logs(
          end_date: cutoff_date
        )

        if export_result.success?
          if content = export_result.content
            File.write(archive_path, content)
            archived_count = content.lines.size - 1 # Minus header
            Log.info { "Archived #{archived_count} audit log entries to #{archive_path}" }
          end
        end
      end

      # Delete old logs
      cleanup_result = cleanup
      deleted_count = cleanup_result.deleted_count

      Result.new(
        success: true,
        deleted_count: deleted_count,
        archived_count: archived_count
      )
    rescue e
      Result.new(success: false, error: e.message)
    end
  end
end
