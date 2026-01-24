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
    property changes : String? # JSONB stored as string
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
      CREATE                = "create"
      UPDATE                = "update"
      DELETE                = "delete"
      LOCK                  = "lock"
      UNLOCK                = "unlock"
      AUTO_LOCK             = "auto_lock"
      AUTO_UNLOCK           = "auto_unlock"
      RESET_PASS            = "reset_password"
      RESET_FAILED_ATTEMPTS = "reset_failed_attempts"
      REGEN_SECRET          = "regenerate_secret"
    end

    # Resource type constants
    module ResourceTypes
      CLIENT = "Client"
      USER   = "User"
      SCOPE  = "Scope"
    end

    # Mapping of action constants to badge CSS classes
    ACTION_BADGE_CLASSES = {
      Actions::CREATE                => "badge-success",
      Actions::UPDATE                => "badge-info",
      Actions::DELETE                => "badge-error",
      Actions::LOCK                  => "badge-warning",
      Actions::AUTO_LOCK             => "badge-warning",
      Actions::UNLOCK                => "badge-success",
      Actions::AUTO_UNLOCK           => "badge-success",
      Actions::RESET_PASS            => "badge-warning",
      Actions::RESET_FAILED_ATTEMPTS => "badge-warning",
      Actions::REGEN_SECRET          => "badge-warning",
    }

    # Returns a badge color class based on action type
    def action_badge_class : String
      ACTION_BADGE_CLASSES.fetch(action, "badge-ghost")
    end

    # Mapping of action constants to human-readable labels
    ACTION_LABELS = {
      Actions::CREATE                => "Created",
      Actions::UPDATE                => "Updated",
      Actions::DELETE                => "Deleted",
      Actions::LOCK                  => "Locked",
      Actions::AUTO_LOCK             => "Auto-Locked",
      Actions::UNLOCK                => "Unlocked",
      Actions::AUTO_UNLOCK           => "Auto-Unlocked",
      Actions::RESET_PASS            => "Password Reset",
      Actions::RESET_FAILED_ATTEMPTS => "Failed Attempts Reset",
      Actions::REGEN_SECRET          => "Secret Regenerated",
    }

    # Returns a human-readable action label
    def action_label : String
      ACTION_LABELS.fetch(action, action.capitalize)
    end
  end
end
