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
      property resource_id : UUID?
      property resource_name : String?
      property changes : Hash(String, Array(String?))?
      property ip_address : String?
      property user_agent : String?

      def initialize(
        @actor : User,
        @action : String,
        @resource_type : String,
        @resource_id : UUID? = nil,
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
      resource_id : UUID? = nil,
      resource_name : String? = nil,
      changes : Hash(String, Array(String?))? = nil,
      ip_address : String? = nil,
      user_agent : String? = nil
    ) : AuditLog?
      # Convert changes to JSON string if provided
      changes_json = changes ? changes.to_json : nil

      id : UUID? = nil

      AuthorityDB.exec_query do |conn|
        result = conn.query_one?(
          "INSERT INTO oauth_audit_logs (" \
          "actor_id, actor_email, action, resource_type, resource_id, " \
          "resource_name, changes, ip_address, user_agent, created_at" \
          ") VALUES (" \
          "$1::uuid, $2, $3, $4, $5::uuid, $6, $7::jsonb, $8::inet, $9, $10" \
          ") RETURNING id",
          actor.id.to_s,
          actor.email,
          action,
          resource_type,
          resource_id.try(&.to_s),
          resource_name,
          changes_json,
          ip_address,
          user_agent,
          Time.utc,
          as: UUID
        )
        id = result
      end

      if audit_id = id
        get(audit_id.to_s)
      else
        nil
      end
    rescue ex
      Log.error { "Failed to create audit log: #{ex.message}" }
      nil
    end

    # Retrieves a single audit log by ID
    def get(id : String) : AuditLog?
      audit_log : AuditLog? = nil

      AuthorityDB.exec_query do |conn|
        conn.query(
          "SELECT id, actor_id, actor_email, action, resource_type, resource_id, " \
          "resource_name, changes::text, ip_address::text, user_agent, created_at " \
          "FROM oauth_audit_logs WHERE id = $1::uuid",
          id
        ) do |rs|
          rs.each do
            log = AuditLog.new
            log.id = rs.read(UUID)
            log.actor_id = rs.read(UUID?)
            log.actor_email = rs.read(String)
            log.action = rs.read(String)
            log.resource_type = rs.read(String)
            log.resource_id = rs.read(UUID?)
            log.resource_name = rs.read(String?)
            log.changes = rs.read(String?)
            log.ip_address = rs.read(String?)
            log.user_agent = rs.read(String?)
            log.created_at = rs.read(Time?)
            audit_log = log
          end
        end
      end

      audit_log
    rescue
      nil
    end

    # Lists audit logs with filtering and pagination
    def list(options : ListOptions = ListOptions.new) : Array(AuditLog)
      logs = [] of AuditLog
      conditions = [] of String
      params = [] of DB::Any
      param_index = 0

      if actor_id = options.actor_id
        param_index += 1
        conditions << "actor_id = $#{param_index}::uuid"
        params << actor_id
      end

      if action = options.action
        param_index += 1
        conditions << "action = $#{param_index}"
        params << action
      end

      if resource_type = options.resource_type
        param_index += 1
        conditions << "resource_type = $#{param_index}"
        params << resource_type
      end

      if start_date = options.start_date
        param_index += 1
        conditions << "created_at >= $#{param_index}::timestamp"
        params << start_date
      end

      if end_date = options.end_date
        param_index += 1
        conditions << "created_at <= $#{param_index}::timestamp"
        params << end_date
      end

      where_clause = conditions.empty? ? "" : "WHERE #{conditions.join(" AND ")}"
      offset = (options.page - 1) * options.per_page

      sql = "SELECT id, actor_id, actor_email, action, resource_type, resource_id, " \
            "resource_name, changes::text, ip_address::text, user_agent, created_at " \
            "FROM oauth_audit_logs #{where_clause} " \
            "ORDER BY created_at DESC LIMIT #{options.per_page} OFFSET #{offset}"

      AuthorityDB.exec_query do |conn|
        conn.query(sql, args: params) do |rs|
          rs.each do
            log = AuditLog.new
            log.id = rs.read(UUID)
            log.actor_id = rs.read(UUID?)
            log.actor_email = rs.read(String)
            log.action = rs.read(String)
            log.resource_type = rs.read(String)
            log.resource_id = rs.read(UUID?)
            log.resource_name = rs.read(String?)
            log.changes = rs.read(String?)
            log.ip_address = rs.read(String?)
            log.user_agent = rs.read(String?)
            log.created_at = rs.read(Time?)
            logs << log
          end
        end
      end

      logs
    rescue ex
      Log.error { "Failed to list audit logs: #{ex.message}" }
      [] of AuditLog
    end

    # Counts total audit logs with optional filtering
    def count(options : ListOptions = ListOptions.new) : Int64
      conditions = [] of String
      params = [] of DB::Any
      param_index = 0

      if actor_id = options.actor_id
        param_index += 1
        conditions << "actor_id = $#{param_index}::uuid"
        params << actor_id
      end

      if action = options.action
        param_index += 1
        conditions << "action = $#{param_index}"
        params << action
      end

      if resource_type = options.resource_type
        param_index += 1
        conditions << "resource_type = $#{param_index}"
        params << resource_type
      end

      if start_date = options.start_date
        param_index += 1
        conditions << "created_at >= $#{param_index}::timestamp"
        params << start_date
      end

      if end_date = options.end_date
        param_index += 1
        conditions << "created_at <= $#{param_index}::timestamp"
        params << end_date
      end

      where_clause = conditions.empty? ? "" : "WHERE #{conditions.join(" AND ")}"
      sql = "SELECT COUNT(*) FROM oauth_audit_logs #{where_clause}"

      count = 0_i64
      AuthorityDB.exec_query do |conn|
        if params.empty?
          count = conn.scalar(sql).as(Int64)
        else
          count = conn.scalar(sql, args: params).as(Int64)
        end
      end

      count
    rescue
      0_i64
    end

    # Gets a list of distinct actions for filtering
    def distinct_actions : Array(String)
      actions = [] of String

      AuthorityDB.exec_query do |conn|
        conn.query("SELECT DISTINCT action FROM oauth_audit_logs ORDER BY action") do |rs|
          rs.each do
            actions << rs.read(String)
          end
        end
      end

      actions
    rescue
      [] of String
    end

    # Gets a list of distinct actors for filtering
    def distinct_actors : Array(NamedTuple(id: String, email: String))
      actors = [] of NamedTuple(id: String, email: String)

      AuthorityDB.exec_query do |conn|
        conn.query("SELECT DISTINCT actor_id, actor_email FROM oauth_audit_logs ORDER BY actor_email") do |rs|
          rs.each do
            actors << {id: rs.read(UUID).to_s, email: rs.read(String)}
          end
        end
      end

      actors
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
