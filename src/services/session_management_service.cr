# Session Management Service
# Provides session tracking, listing, and revocation for users.
module Authority
  class SessionManagementService
    # Default session duration (7 days)
    SESSION_DURATION = 7.days

    # Result struct for service operations
    struct Result
      getter? success : Bool
      getter session : PersistentSession?
      getter error : String?
      getter error_code : String?

      def initialize(
        @success : Bool,
        @session : PersistentSession? = nil,
        @error : String? = nil,
        @error_code : String? = nil
      )
      end
    end

    # Create a new session for a user
    def self.create(
      user_id : String,
      ip_address : String? = nil,
      user_agent : String? = nil
    ) : Result
      now = Time.utc
      session_token = PersistentSession.generate_token
      device_info = PersistentSession.parse_device_info(user_agent)

      session = PersistentSession.new
      session.user_id = UUID.new(user_id)
      session.session_token = session_token
      session.ip_address = ip_address
      session.user_agent = user_agent
      session.device_info = device_info
      session.last_activity_at = now
      session.expires_at = now + SESSION_DURATION
      session.created_at = now
      session.save!

      Result.new(success: true, session: session)
    rescue e
      Result.new(success: false, error: e.message, error_code: "create_failed")
    end

    # Find session by token
    def self.find_by_token(token : String) : PersistentSession?
      PersistentSession.find_by(session_token: token)
    rescue
      nil
    end

    # Update session last activity
    def self.touch(token : String, ip_address : String? = nil) : Result
      session = find_by_token(token)
      return Result.new(success: false, error: "Session not found", error_code: "not_found") unless session

      return Result.new(success: false, error: "Session expired", error_code: "expired") if session.expired?
      return Result.new(success: false, error: "Session revoked", error_code: "revoked") if session.revoked?

      session.last_activity_at = Time.utc
      if ip_address
        session.ip_address = ip_address
      end
      session.update!

      Result.new(success: true, session: session)
    rescue e
      Result.new(success: false, error: e.message, error_code: "touch_failed")
    end

    # List active sessions for a user
    def self.list_for_user(user_id : String) : Array(PersistentSession)
      now = Time.utc
      PersistentSession.query
        .where(user_id: user_id)
        .order(last_activity_at: :desc)
        .all
        .select { |session| !session.revoked? && session.expires_at > now }
    rescue
      [] of PersistentSession
    end

    # List all sessions for a user (including revoked/expired)
    def self.list_all_for_user(user_id : String) : Array(PersistentSession)
      PersistentSession.query
        .where(user_id: user_id)
        .order(last_activity_at: :desc)
        .all
    rescue
      [] of PersistentSession
    end

    # Revoke a specific session
    def self.revoke(
      session_id : String,
      actor : User? = nil,
      ip_address : String? = nil
    ) : Result
      session = PersistentSession.find(UUID.new(session_id))
      return Result.new(success: false, error: "Session not found", error_code: "not_found") unless session

      session.revoked_at = Time.utc
      session.update!

      # Log audit trail if actor provided
      if actor
        AuditService.log(
          actor: actor,
          action: "revoke_session",
          resource_type: "session",
          resource_id: session_id,
          resource_name: session.device_info || "Unknown Device",
          ip_address: ip_address
        )
      end

      Result.new(success: true, session: session)
    rescue e
      Result.new(success: false, error: e.message, error_code: "revoke_failed")
    end

    # Revoke all sessions for a user (except optionally the current one)
    def self.revoke_all_for_user(
      user_id : String,
      except_token : String? = nil,
      actor : User? = nil,
      ip_address : String? = nil
    ) : Int32
      now = Time.utc
      sessions = list_for_user(user_id)
      revoked_count = 0

      sessions.each do |session|
        # Skip current session if requested
        next if except_token && session.session_token == except_token

        session.revoked_at = now
        session.update!
        revoked_count += 1
      end

      # Log audit trail if actor provided
      if actor && revoked_count > 0
        AuditService.log(
          actor: actor,
          action: "revoke_all_sessions",
          resource_type: AuditLog::ResourceTypes::USER,
          resource_id: user_id,
          resource_name: actor.username,
          changes: {"sessions_revoked" => [nil.as(String?), revoked_count.to_s.as(String?)]},
          ip_address: ip_address
        )
      end

      revoked_count
    rescue
      0
    end

    # Count active sessions for a user
    def self.count_active_for_user(user_id : String) : Int32
      list_for_user(user_id).size
    end

    # Clean up expired sessions (for periodic maintenance)
    def self.cleanup_expired : Int32
      cutoff = Time.utc - 30.days # Keep expired sessions for 30 days for auditing
      deleted = 0

      PersistentSession.query.all.each do |session|
        should_delete = session.expires_at < cutoff
        if revoked_at = session.revoked_at
          should_delete ||= revoked_at < cutoff
        end
        if should_delete
          session.delete!
          deleted += 1
        end
      end

      deleted
    rescue
      0
    end

    # Validate and refresh a session
    def self.validate(token : String, ip_address : String? = nil) : Result
      session = find_by_token(token)
      return Result.new(success: false, error: "Session not found", error_code: "not_found") unless session

      if session.revoked?
        return Result.new(success: false, error: "Session revoked", error_code: "revoked")
      end

      if session.expired?
        return Result.new(success: false, error: "Session expired", error_code: "expired")
      end

      # Update last activity
      session.last_activity_at = Time.utc
      if ip_address
        session.ip_address = ip_address
      end
      session.update!

      Result.new(success: true, session: session)
    rescue e
      Result.new(success: false, error: e.message, error_code: "validate_failed")
    end
  end
end
