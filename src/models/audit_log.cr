module Authority
  @[Crinja::Attributes(expose: [id_str, actor_id_str, actor_email, action, resource_type, resource_id_str, resource_name, ip_address, user_agent, created_at, action_badge_class, action_label])]
  class AuditLog
    include CQL::ActiveRecord::Model(UUID)
    include Crinja::Object::Auto
    db_context AuthorityDB, :oauth_audit_logs

    property actor_id : UUID?
    property actor_email : String = ""
    property action : String = ""
    property resource_type : String = ""
    property resource_id : UUID?
    property resource_name : String?
    property changes : String?  # JSONB stored as string
    property ip_address : String?
    property user_agent : String?
    property created_at : Time?

    def initialize
    end

    # Returns UUID as string for template rendering
    def id_str : String
      id.to_s
    end

    def actor_id_str : String?
      actor_id.try(&.to_s)
    end

    def resource_id_str : String?
      resource_id.try(&.to_s)
    end

    # Action constants for consistency
    module Actions
      CREATE              = "create"
      UPDATE              = "update"
      DELETE              = "delete"
      LOCK                = "lock"
      UNLOCK              = "unlock"
      AUTO_LOCK           = "auto_lock"
      AUTO_UNLOCK         = "auto_unlock"
      RESET_PASS          = "reset_password"
      RESET_FAILED_ATTEMPTS = "reset_failed_attempts"
      REGEN_SECRET        = "regenerate_secret"
    end

    # Resource type constants
    module ResourceTypes
      CLIENT = "Client"
      USER   = "User"
      SCOPE  = "Scope"
    end

    # Returns a badge color class based on action type
    def action_badge_class : String
      case action
      when Actions::CREATE
        "badge-success"
      when Actions::UPDATE
        "badge-info"
      when Actions::DELETE
        "badge-error"
      when Actions::LOCK, Actions::AUTO_LOCK
        "badge-warning"
      when Actions::UNLOCK, Actions::AUTO_UNLOCK
        "badge-success"
      when Actions::RESET_PASS, Actions::RESET_FAILED_ATTEMPTS
        "badge-warning"
      when Actions::REGEN_SECRET
        "badge-warning"
      else
        "badge-ghost"
      end
    end

    # Returns a human-readable action label
    def action_label : String
      case action
      when Actions::CREATE
        "Created"
      when Actions::UPDATE
        "Updated"
      when Actions::DELETE
        "Deleted"
      when Actions::LOCK
        "Locked"
      when Actions::AUTO_LOCK
        "Auto-Locked"
      when Actions::UNLOCK
        "Unlocked"
      when Actions::AUTO_UNLOCK
        "Auto-Unlocked"
      when Actions::RESET_PASS
        "Password Reset"
      when Actions::RESET_FAILED_ATTEMPTS
        "Failed Attempts Reset"
      when Actions::REGEN_SECRET
        "Secret Regenerated"
      else
        action.capitalize
      end
    end
  end
end
