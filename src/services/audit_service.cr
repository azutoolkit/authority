require "json"

module Authority
  # AuditService provides audit logging functionality for admin actions.
  # All admin operations should call this service to maintain an audit trail.
  module AuditService
    extend self

    struct LogEntry
      property actor : User
      property action : String
      property resource_type : String
      property resource_id : String?
      property resource_name : String?
      property changes : Hash(String, Array(String?))?
      property ip_address : String?
      property user_agent : String?

      def initialize(
        @actor : User,
        @action : String,
        @resource_type : String,
        @resource_id : String? = nil,
        @resource_name : String? = nil,
        @changes : Hash(String, Array(String?))? = nil,
        @ip_address : String? = nil,
        @user_agent : String? = nil
      )
      end
    end

    struct ListOptions
      property page : Int32 = 1
      property per_page : Int32 = 20
      property actor_id : String?
      property action : String?
      property resource_type : String?
      property start_date : Time?
      property end_date : Time?

      def initialize(
        @page : Int32 = 1,
        @per_page : Int32 = 20,
        @actor_id : String? = nil,
        @action : String? = nil,
        @resource_type : String? = nil,
        @start_date : Time? = nil,
        @end_date : Time? = nil
      )
      end
    end

    # Logs an audit event to the database
    def log(entry : LogEntry) : AuditLog?
      log(
        actor: entry.actor,
        action: entry.action,
        resource_type: entry.resource_type,
        resource_id: entry.resource_id,
        resource_name: entry.resource_name,
        changes: entry.changes,
        ip_address: entry.ip_address,
        user_agent: entry.user_agent
      )
    end

    # Logs an audit event to the database
    def log(
      actor : User,
      action : String,
      resource_type : String,
      resource_id : String? = nil,
      resource_name : String? = nil,
      changes : Hash(String, Array(String?))? = nil,
      ip_address : String? = nil,
      user_agent : String? = nil
    ) : AuditLog?
      audit = AuditLog.new
      audit.actor_id = UUID.new(actor.id.to_s)
      audit.actor_email = actor.email
      audit.action = action
      audit.resource_type = resource_type
      audit.resource_id = resource_id.try { |id| UUID.new(id) }
      audit.resource_name = resource_name
      audit.changes = changes.try(&.to_json)
      audit.ip_address = ip_address
      audit.user_agent = user_agent
      audit.created_at = Time.utc
      audit.save!
      audit
    rescue ex
      Log.error { "Failed to create audit log: #{ex.message}" }
      nil
    end

    # Retrieves a single audit log by ID
    def get(id : String) : AuditLog?
      AuditLog.find(UUID.new(id))
    rescue
      nil
    end

    # Lists audit logs with filtering and pagination
    def list(options : ListOptions = ListOptions.new) : Array(AuditLog)
      offset = (options.page - 1) * options.per_page

      query = AuditLog.query

      if actor_id = options.actor_id
        query = query.where(actor_id: UUID.new(actor_id).to_s)
      end

      if action = options.action
        query = query.where(action: action)
      end

      if resource_type = options.resource_type
        query = query.where(resource_type: resource_type)
      end

      # Fetch results with ordering and pagination
      results = query.order(created_at: :desc)
        .limit(options.per_page)
        .offset(offset)
        .all

      # Apply date filters in memory (block DSL doesn't work outside model context)
      filter_by_date(results, options.start_date, options.end_date)
    rescue ex
      Log.error { "Failed to list audit logs: #{ex.message}" }
      [] of AuditLog
    end

    # Filter audit logs by date range
    private def filter_by_date(logs : Array(AuditLog), start_date : Time?, end_date : Time?) : Array(AuditLog)
      return logs unless start_date || end_date

      logs.select do |log|
        created = log.created_at
        next false unless created
        next false if start_date && created < start_date
        next false if end_date && created > end_date
        true
      end
    end

    # Counts total audit logs with optional filtering
    def count(options : ListOptions = ListOptions.new) : Int64
      query = AuditLog.query

      if actor_id = options.actor_id
        query = query.where(actor_id: UUID.new(actor_id).to_s)
      end

      if action = options.action
        query = query.where(action: action)
      end

      if resource_type = options.resource_type
        query = query.where(resource_type: resource_type)
      end

      # If date filters are needed, count in memory
      if options.start_date || options.end_date
        filter_by_date(query.all, options.start_date, options.end_date).size.to_i64
      else
        query.count.to_i64
      end
    rescue
      0_i64
    end

    # Gets a list of distinct actions for filtering
    def distinct_actions : Array(String)
      actions = Set(String).new
      AuditLog.all.each do |log|
        actions << log.action
      end
      actions.to_a.sort
    rescue
      [] of String
    end

    # Gets a list of distinct actors for filtering
    def distinct_actors : Array(NamedTuple(id: String, email: String))
      seen = Set(String).new
      actors = [] of NamedTuple(id: String, email: String)

      AuditLog.all.each do |log|
        if actor_id = log.actor_id
          key = actor_id.to_s
          unless seen.includes?(key)
            seen << key
            actors << {id: key, email: log.actor_email}
          end
        end
      end

      actors.sort_by(&.[:email])
    rescue
      [] of NamedTuple(id: String, email: String)
    end

    # Calculates the changes between old and new values
    def diff(old_values : Hash(String, String?), new_values : Hash(String, String?)) : Hash(String, Array(String?))
      changes = {} of String => Array(String?)

      # Find changed and removed keys
      old_values.each do |key, old_val|
        new_val = new_values[key]?
        if old_val != new_val
          changes[key] = [old_val, new_val]
        end
      end

      # Find added keys
      new_values.each do |key, new_val|
        unless old_values.has_key?(key)
          changes[key] = [nil, new_val]
        end
      end

      changes
    end
  end
end
