# Analytics Service
# Provides statistics and metrics for the admin dashboard.
module Authority
  module AnalyticsService
    extend self

    # Dashboard statistics
    struct DashboardStats
      getter total_users : Int64
      getter total_clients : Int64
      getter total_scopes : Int64
      getter active_users : Int64       # Users logged in within 7 days
      getter locked_users : Int64
      getter failed_logins_24h : Int64
      getter new_users_7d : Int64
      getter new_clients_7d : Int64

      def initialize(
        @total_users : Int64 = 0,
        @total_clients : Int64 = 0,
        @total_scopes : Int64 = 0,
        @active_users : Int64 = 0,
        @locked_users : Int64 = 0,
        @failed_logins_24h : Int64 = 0,
        @new_users_7d : Int64 = 0,
        @new_clients_7d : Int64 = 0
      )
      end
    end

    # Login activity data point
    struct LoginActivity
      getter date : String  # YYYY-MM-DD
      getter successful : Int32
      getter failed : Int32

      def initialize(@date : String, @successful : Int32, @failed : Int32)
      end
    end

    # Recent audit log entry for display
    struct RecentActivity
      getter action : String
      getter resource_type : String
      getter resource_name : String
      getter actor_email : String
      getter created_at : Time?
      getter action_badge_class : String

      def initialize(
        @action : String,
        @resource_type : String,
        @resource_name : String,
        @actor_email : String,
        @created_at : Time?,
        @action_badge_class : String
      )
      end
    end

    # Get dashboard statistics
    def get_dashboard_stats : DashboardStats
      total_users = User.query.count.to_i64
      total_clients = Client.query.count.to_i64
      total_scopes = Scope.query.count.to_i64

      # Count active users (logged in within 7 days)
      seven_days_ago = 7.days.ago
      active_users = User.query.all.count { |u| u.last_login_at && u.last_login_at.not_nil! > seven_days_ago }.to_i64

      # Count locked users
      locked_users = User.query.all.count { |u| u.locked? }.to_i64

      # Count failed logins in last 24 hours (from audit logs)
      twenty_four_hours_ago = 24.hours.ago
      failed_logins_24h = AuditLog.query.all.count do |log|
        log.action == "login_failed" && log.created_at && log.created_at.not_nil! > twenty_four_hours_ago
      end.to_i64

      # New users in last 7 days
      new_users_7d = User.query.all.count { |u| u.created_at && u.created_at.not_nil! > seven_days_ago }.to_i64

      # New clients in last 7 days
      new_clients_7d = Client.query.all.count { |c| c.created_at && c.created_at.not_nil! > seven_days_ago }.to_i64

      DashboardStats.new(
        total_users: total_users,
        total_clients: total_clients,
        total_scopes: total_scopes,
        active_users: active_users,
        locked_users: locked_users,
        failed_logins_24h: failed_logins_24h,
        new_users_7d: new_users_7d,
        new_clients_7d: new_clients_7d
      )
    end

    # Get login activity for the last N days (for charts)
    def get_login_activity(days : Int32 = 7) : Array(LoginActivity)
      activity = [] of LoginActivity
      today = Time.utc.at_beginning_of_day

      days.times do |i|
        date = today - i.days
        date_str = date.to_s("%Y-%m-%d")

        # Count successful and failed logins for this day
        # This is a simplified version - in production, you'd query audit logs
        # For now, we'll generate placeholder data or count from audit logs
        successful = count_logins_for_date(date, true)
        failed = count_logins_for_date(date, false)

        activity << LoginActivity.new(date_str, successful, failed)
      end

      # Reverse to get oldest first (for chart display)
      activity.reverse
    end

    # Get recent activity from audit logs
    def get_recent_activity(limit : Int32 = 10) : Array(RecentActivity)
      logs = AuditService.list(AuditService::ListOptions.new(page: 1, per_page: limit))

      logs.map do |log|
        RecentActivity.new(
          action: log.action_label,
          resource_type: log.resource_type,
          resource_name: log.resource_name || "Unknown",
          actor_email: log.actor_email,
          created_at: log.created_at,
          action_badge_class: log.action_badge_class
        )
      end
    end

    # Get user role distribution
    def get_user_roles : Hash(String, Int64)
      roles = Hash(String, Int64).new(0_i64)

      User.query.all.each do |user|
        roles[user.role] = roles[user.role] + 1
      end

      roles
    end

    # Get client confidentiality distribution
    def get_client_types : NamedTuple(confidential: Int64, public_clients: Int64)
      confidential = Client.query.all.count { |c| c.is_confidential }.to_i64
      public_clients = Client.query.all.count { |c| !c.is_confidential }.to_i64

      {confidential: confidential, public_clients: public_clients}
    end

    # Get scope usage stats
    def get_scope_usage : Array(NamedTuple(name: String, count: Int64))
      scope_counts = Hash(String, Int64).new(0_i64)

      # Count scope usage across all clients
      Client.query.all.each do |client|
        client.scopes_list.each do |scope|
          scope_counts[scope] = scope_counts[scope] + 1
        end
      end

      # Sort by count descending
      scope_counts.map { |name, count| {name: name, count: count} }
        .sort_by { |s| -s[:count] }
        .first(10)
    end

    # Count logins for a specific date
    private def count_logins_for_date(date : Time, successful : Bool) : Int32
      next_day = date + 1.day

      # Count from audit logs if available
      action = successful ? AuditLog::Actions::UPDATE : "login_failed"

      AuditLog.query.all.count do |log|
        matches_action = if successful
                           log.action == AuditLog::Actions::UPDATE &&
                             log.resource_type == AuditLog::ResourceTypes::USER &&
                             log.changes.try(&.includes?("last_login_at"))
                         else
                           log.action == "login_failed"
                         end

        matches_date = log.created_at &&
                       log.created_at.not_nil! >= date &&
                       log.created_at.not_nil! < next_day

        matches_action && matches_date
      end.to_i32
    end
  end
end
