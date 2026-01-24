# Setting model for storing system configuration in the database.
module Authority
  @[Crinja::Attributes(expose: [id_str, key, value, category, description, updated_at, updated_by])]
  struct Setting
    include CQL::ActiveRecord::Model(UUID)
    include Crinja::Object::Auto
    db_context AuthorityDB, :settings

    # Core fields
    property key : String = ""
    property value : String?
    property category : String = ""
    property description : String?
    property updated_at : Time = Time.utc
    property updated_by : String?

    # Category constants
    module Categories
      SECURITY  = "security"
      EMAIL     = "email"
      AUDIT     = "audit"
      BRANDING  = "branding"
      SOCIAL    = "social"
    end

    # Setting key constants
    module Keys
      # Security
      LOCKOUT_THRESHOLD           = "lockout_threshold"
      LOCKOUT_DURATION_MINUTES    = "lockout_duration_minutes"
      AUTO_UNLOCK_ENABLED         = "auto_unlock_enabled"
      SESSION_DURATION_DAYS       = "session_duration_days"
      PASSWORD_MIN_LENGTH         = "password_min_length"
      PASSWORD_REQUIRE_UPPERCASE  = "password_require_uppercase"
      PASSWORD_REQUIRE_LOWERCASE  = "password_require_lowercase"
      PASSWORD_REQUIRE_NUMBER     = "password_require_number"
      PASSWORD_REQUIRE_SPECIAL    = "password_require_special"
      PASSWORD_HISTORY_COUNT      = "password_history_count"

      # Email
      SMTP_ENABLED                = "smtp_enabled"
      SMTP_HOST                   = "smtp_host"
      SMTP_PORT                   = "smtp_port"
      SMTP_USERNAME               = "smtp_username"
      SMTP_FROM_ADDRESS           = "smtp_from_address"
      SMTP_FROM_NAME              = "smtp_from_name"

      # Audit
      AUDIT_RETENTION_DAYS        = "audit_retention_days"
      AUDIT_LOG_LEVEL             = "audit_log_level"

      # Branding
      APP_NAME                    = "app_name"
      APP_LOGO_URL                = "app_logo_url"
      PRIMARY_COLOR               = "primary_color"
      SUPPORT_EMAIL               = "support_email"

      # Social Login - Google
      GOOGLE_OAUTH_ENABLED        = "google_oauth_enabled"
      GOOGLE_CLIENT_ID            = "google_client_id"
      GOOGLE_CLIENT_SECRET        = "google_client_secret"

      # Social Login - Facebook
      FACEBOOK_OAUTH_ENABLED      = "facebook_oauth_enabled"
      FACEBOOK_CLIENT_ID          = "facebook_client_id"
      FACEBOOK_CLIENT_SECRET      = "facebook_client_secret"

      # Social Login - Apple
      APPLE_OAUTH_ENABLED         = "apple_oauth_enabled"
      APPLE_CLIENT_ID             = "apple_client_id"
      APPLE_TEAM_ID               = "apple_team_id"
      APPLE_KEY_ID                = "apple_key_id"
      APPLE_PRIVATE_KEY           = "apple_private_key"

      # Social Login - LinkedIn
      LINKEDIN_OAUTH_ENABLED      = "linkedin_oauth_enabled"
      LINKEDIN_CLIENT_ID          = "linkedin_client_id"
      LINKEDIN_CLIENT_SECRET      = "linkedin_client_secret"

      # Social Login - GitHub
      GITHUB_OAUTH_ENABLED        = "github_oauth_enabled"
      GITHUB_CLIENT_ID            = "github_client_id"
      GITHUB_CLIENT_SECRET        = "github_client_secret"
    end

    def initialize
    end

    # Helper to get string ID for templates
    def id_str : String
      id.to_s
    end
  end
end
