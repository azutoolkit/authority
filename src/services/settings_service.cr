# Settings Service
# Provides CRUD operations for system settings with caching support.
module Authority
  class SettingsService
    # In-memory cache for settings (invalidated on update)
    @@cache : Hash(String, String?) = {} of String => String?
    @@cache_loaded : Bool = false

    # Result struct for service operations
    struct Result
      getter? success : Bool
      getter setting : Setting?
      getter error : String?

      def initialize(
        @success : Bool,
        @setting : Setting? = nil,
        @error : String? = nil
      )
      end
    end

    # Get a setting value by key with fallback to default
    def self.get(key : String, default : String? = nil) : String?
      load_cache unless @@cache_loaded
      @@cache.fetch(key, default)
    end

    # Get a setting value as boolean
    def self.get_bool(key : String, default : Bool = false) : Bool
      value = get(key)
      return default if value.nil?
      value == "true" || value == "1" || value == "yes"
    end

    # Get a setting value as integer
    def self.get_int(key : String, default : Int32 = 0) : Int32
      value = get(key)
      return default if value.nil?
      value.to_i32? || default
    end

    # Set a setting value
    def self.set(
      key : String,
      value : String?,
      category : String = "general",
      description : String? = nil,
      updated_by : String? = nil
    ) : Result
      setting = Setting.find_by(key: key)

      if setting
        setting.value = value
        setting.updated_at = Time.utc
        setting.updated_by = updated_by
        setting.update!
      else
        setting = Setting.new
        setting.key = key
        setting.value = value
        setting.category = category
        setting.description = description
        setting.updated_at = Time.utc
        setting.updated_by = updated_by
        setting.save!
      end

      # Invalidate cache
      @@cache[key] = value
      @@cache_loaded = false

      Result.new(success: true, setting: setting)
    rescue e
      Result.new(success: false, error: e.message)
    end

    # Get all settings for a category
    def self.list_by_category(category : String) : Array(Setting)
      Setting.query.where(category: category).all
    rescue
      [] of Setting
    end

    # Get all settings
    def self.list_all : Array(Setting)
      Setting.query.order(category: :asc).all
    rescue
      [] of Setting
    end

    # Delete a setting
    def self.delete(key : String) : Result
      setting = Setting.find_by(key: key)
      return Result.new(success: false, error: "Setting not found") unless setting

      setting.delete!
      @@cache.delete(key)

      Result.new(success: true)
    rescue e
      Result.new(success: false, error: e.message)
    end

    # Load all settings into cache
    def self.load_cache
      @@cache.clear
      Setting.query.all.each do |setting|
        @@cache[setting.key] = setting.value
      end
      @@cache_loaded = true
    rescue
      # Ignore errors during cache load
    end

    # Invalidate cache
    def self.invalidate_cache
      @@cache_loaded = false
    end

    # Initialize default settings if they don't exist
    def self.initialize_defaults
      defaults = {
        # Security defaults
        {Setting::Keys::LOCKOUT_THRESHOLD, "5", Setting::Categories::SECURITY, "Failed login attempts before lockout"},
        {Setting::Keys::LOCKOUT_DURATION_MINUTES, "30", Setting::Categories::SECURITY, "Minutes until automatic unlock"},
        {Setting::Keys::AUTO_UNLOCK_ENABLED, "true", Setting::Categories::SECURITY, "Automatically unlock accounts after lockout duration"},
        {Setting::Keys::SESSION_DURATION_DAYS, "7", Setting::Categories::SECURITY, "Days until session expires"},
        {Setting::Keys::PASSWORD_MIN_LENGTH, "12", Setting::Categories::SECURITY, "Minimum password length"},
        {Setting::Keys::PASSWORD_REQUIRE_UPPERCASE, "true", Setting::Categories::SECURITY, "Require uppercase letter in password"},
        {Setting::Keys::PASSWORD_REQUIRE_LOWERCASE, "true", Setting::Categories::SECURITY, "Require lowercase letter in password"},
        {Setting::Keys::PASSWORD_REQUIRE_NUMBER, "true", Setting::Categories::SECURITY, "Require number in password"},
        {Setting::Keys::PASSWORD_REQUIRE_SPECIAL, "true", Setting::Categories::SECURITY, "Require special character in password"},
        {Setting::Keys::PASSWORD_HISTORY_COUNT, "5", Setting::Categories::SECURITY, "Number of previous passwords to prevent reuse"},

        # Email defaults
        {Setting::Keys::SMTP_ENABLED, "false", Setting::Categories::EMAIL, "Enable SMTP email sending"},
        {Setting::Keys::SMTP_HOST, "localhost", Setting::Categories::EMAIL, "SMTP server hostname"},
        {Setting::Keys::SMTP_PORT, "587", Setting::Categories::EMAIL, "SMTP server port"},
        {Setting::Keys::SMTP_USERNAME, "", Setting::Categories::EMAIL, "SMTP authentication username"},
        {Setting::Keys::SMTP_FROM_ADDRESS, "noreply@authority.local", Setting::Categories::EMAIL, "From email address"},
        {Setting::Keys::SMTP_FROM_NAME, "Authority", Setting::Categories::EMAIL, "From display name"},

        # Audit defaults
        {Setting::Keys::AUDIT_RETENTION_DAYS, "365", Setting::Categories::AUDIT, "Days to retain audit logs"},
        {Setting::Keys::AUDIT_LOG_LEVEL, "all", Setting::Categories::AUDIT, "Audit log level (all, important, errors)"},

        # Branding defaults
        {Setting::Keys::APP_NAME, "Authority", Setting::Categories::BRANDING, "Application name displayed in UI"},
        {Setting::Keys::APP_LOGO_URL, "", Setting::Categories::BRANDING, "URL to logo image"},
        {Setting::Keys::PRIMARY_COLOR, "#570df8", Setting::Categories::BRANDING, "Primary brand color (hex)"},
        {Setting::Keys::SUPPORT_EMAIL, "", Setting::Categories::BRANDING, "Support contact email"},

        # Social Login defaults - Google
        {Setting::Keys::GOOGLE_OAUTH_ENABLED, "false", Setting::Categories::SOCIAL, "Enable Google OAuth login"},
        {Setting::Keys::GOOGLE_CLIENT_ID, "", Setting::Categories::SOCIAL, "Google OAuth Client ID"},
        {Setting::Keys::GOOGLE_CLIENT_SECRET, "", Setting::Categories::SOCIAL, "Google OAuth Client Secret"},

        # Social Login defaults - Facebook
        {Setting::Keys::FACEBOOK_OAUTH_ENABLED, "false", Setting::Categories::SOCIAL, "Enable Facebook OAuth login"},
        {Setting::Keys::FACEBOOK_CLIENT_ID, "", Setting::Categories::SOCIAL, "Facebook OAuth App ID"},
        {Setting::Keys::FACEBOOK_CLIENT_SECRET, "", Setting::Categories::SOCIAL, "Facebook OAuth App Secret"},

        # Social Login defaults - Apple
        {Setting::Keys::APPLE_OAUTH_ENABLED, "false", Setting::Categories::SOCIAL, "Enable Sign in with Apple"},
        {Setting::Keys::APPLE_CLIENT_ID, "", Setting::Categories::SOCIAL, "Apple Service ID"},
        {Setting::Keys::APPLE_TEAM_ID, "", Setting::Categories::SOCIAL, "Apple Team ID"},
        {Setting::Keys::APPLE_KEY_ID, "", Setting::Categories::SOCIAL, "Apple Key ID"},
        {Setting::Keys::APPLE_PRIVATE_KEY, "", Setting::Categories::SOCIAL, "Apple Private Key (.p8 contents)"},

        # Social Login defaults - LinkedIn
        {Setting::Keys::LINKEDIN_OAUTH_ENABLED, "false", Setting::Categories::SOCIAL, "Enable LinkedIn OAuth login"},
        {Setting::Keys::LINKEDIN_CLIENT_ID, "", Setting::Categories::SOCIAL, "LinkedIn OAuth Client ID"},
        {Setting::Keys::LINKEDIN_CLIENT_SECRET, "", Setting::Categories::SOCIAL, "LinkedIn OAuth Client Secret"},

        # Social Login defaults - GitHub
        {Setting::Keys::GITHUB_OAUTH_ENABLED, "false", Setting::Categories::SOCIAL, "Enable GitHub OAuth login"},
        {Setting::Keys::GITHUB_CLIENT_ID, "", Setting::Categories::SOCIAL, "GitHub OAuth Client ID"},
        {Setting::Keys::GITHUB_CLIENT_SECRET, "", Setting::Categories::SOCIAL, "GitHub OAuth Client Secret"},
      }

      defaults.each do |key, value, category, description|
        # Only set if not already exists
        unless Setting.find_by(key: key)
          set(key, value, category, description, "system")
        end
      end
    end

    # Get settings as a grouped hash for the UI
    def self.get_all_grouped : Hash(String, Hash(String, String?))
      load_cache unless @@cache_loaded

      result = {
        "security" => {} of String => String?,
        "email"    => {} of String => String?,
        "audit"    => {} of String => String?,
        "branding" => {} of String => String?,
        "social"   => {} of String => String?,
      }

      # Security
      result["security"][Setting::Keys::LOCKOUT_THRESHOLD] = get(Setting::Keys::LOCKOUT_THRESHOLD, "5")
      result["security"][Setting::Keys::LOCKOUT_DURATION_MINUTES] = get(Setting::Keys::LOCKOUT_DURATION_MINUTES, "30")
      result["security"][Setting::Keys::AUTO_UNLOCK_ENABLED] = get(Setting::Keys::AUTO_UNLOCK_ENABLED, "true")
      result["security"][Setting::Keys::SESSION_DURATION_DAYS] = get(Setting::Keys::SESSION_DURATION_DAYS, "7")
      result["security"][Setting::Keys::PASSWORD_MIN_LENGTH] = get(Setting::Keys::PASSWORD_MIN_LENGTH, "12")
      result["security"][Setting::Keys::PASSWORD_REQUIRE_UPPERCASE] = get(Setting::Keys::PASSWORD_REQUIRE_UPPERCASE, "true")
      result["security"][Setting::Keys::PASSWORD_REQUIRE_LOWERCASE] = get(Setting::Keys::PASSWORD_REQUIRE_LOWERCASE, "true")
      result["security"][Setting::Keys::PASSWORD_REQUIRE_NUMBER] = get(Setting::Keys::PASSWORD_REQUIRE_NUMBER, "true")
      result["security"][Setting::Keys::PASSWORD_REQUIRE_SPECIAL] = get(Setting::Keys::PASSWORD_REQUIRE_SPECIAL, "true")
      result["security"][Setting::Keys::PASSWORD_HISTORY_COUNT] = get(Setting::Keys::PASSWORD_HISTORY_COUNT, "5")

      # Email
      result["email"][Setting::Keys::SMTP_ENABLED] = get(Setting::Keys::SMTP_ENABLED, "false")
      result["email"][Setting::Keys::SMTP_HOST] = get(Setting::Keys::SMTP_HOST, "localhost")
      result["email"][Setting::Keys::SMTP_PORT] = get(Setting::Keys::SMTP_PORT, "587")
      result["email"][Setting::Keys::SMTP_USERNAME] = get(Setting::Keys::SMTP_USERNAME, "")
      result["email"][Setting::Keys::SMTP_FROM_ADDRESS] = get(Setting::Keys::SMTP_FROM_ADDRESS, "noreply@authority.local")
      result["email"][Setting::Keys::SMTP_FROM_NAME] = get(Setting::Keys::SMTP_FROM_NAME, "Authority")

      # Audit
      result["audit"][Setting::Keys::AUDIT_RETENTION_DAYS] = get(Setting::Keys::AUDIT_RETENTION_DAYS, "365")
      result["audit"][Setting::Keys::AUDIT_LOG_LEVEL] = get(Setting::Keys::AUDIT_LOG_LEVEL, "all")

      # Branding
      result["branding"][Setting::Keys::APP_NAME] = get(Setting::Keys::APP_NAME, "Authority")
      result["branding"][Setting::Keys::APP_LOGO_URL] = get(Setting::Keys::APP_LOGO_URL, "")
      result["branding"][Setting::Keys::PRIMARY_COLOR] = get(Setting::Keys::PRIMARY_COLOR, "#570df8")
      result["branding"][Setting::Keys::SUPPORT_EMAIL] = get(Setting::Keys::SUPPORT_EMAIL, "")

      # Social Login - Google
      result["social"][Setting::Keys::GOOGLE_OAUTH_ENABLED] = get(Setting::Keys::GOOGLE_OAUTH_ENABLED, "false")
      result["social"][Setting::Keys::GOOGLE_CLIENT_ID] = get(Setting::Keys::GOOGLE_CLIENT_ID, "")
      result["social"][Setting::Keys::GOOGLE_CLIENT_SECRET] = get(Setting::Keys::GOOGLE_CLIENT_SECRET, "")

      # Social Login - Facebook
      result["social"][Setting::Keys::FACEBOOK_OAUTH_ENABLED] = get(Setting::Keys::FACEBOOK_OAUTH_ENABLED, "false")
      result["social"][Setting::Keys::FACEBOOK_CLIENT_ID] = get(Setting::Keys::FACEBOOK_CLIENT_ID, "")
      result["social"][Setting::Keys::FACEBOOK_CLIENT_SECRET] = get(Setting::Keys::FACEBOOK_CLIENT_SECRET, "")

      # Social Login - Apple
      result["social"][Setting::Keys::APPLE_OAUTH_ENABLED] = get(Setting::Keys::APPLE_OAUTH_ENABLED, "false")
      result["social"][Setting::Keys::APPLE_CLIENT_ID] = get(Setting::Keys::APPLE_CLIENT_ID, "")
      result["social"][Setting::Keys::APPLE_TEAM_ID] = get(Setting::Keys::APPLE_TEAM_ID, "")
      result["social"][Setting::Keys::APPLE_KEY_ID] = get(Setting::Keys::APPLE_KEY_ID, "")
      result["social"][Setting::Keys::APPLE_PRIVATE_KEY] = get(Setting::Keys::APPLE_PRIVATE_KEY, "")

      # Social Login - LinkedIn
      result["social"][Setting::Keys::LINKEDIN_OAUTH_ENABLED] = get(Setting::Keys::LINKEDIN_OAUTH_ENABLED, "false")
      result["social"][Setting::Keys::LINKEDIN_CLIENT_ID] = get(Setting::Keys::LINKEDIN_CLIENT_ID, "")
      result["social"][Setting::Keys::LINKEDIN_CLIENT_SECRET] = get(Setting::Keys::LINKEDIN_CLIENT_SECRET, "")

      # Social Login - GitHub
      result["social"][Setting::Keys::GITHUB_OAUTH_ENABLED] = get(Setting::Keys::GITHUB_OAUTH_ENABLED, "false")
      result["social"][Setting::Keys::GITHUB_CLIENT_ID] = get(Setting::Keys::GITHUB_CLIENT_ID, "")
      result["social"][Setting::Keys::GITHUB_CLIENT_SECRET] = get(Setting::Keys::GITHUB_CLIENT_SECRET, "")

      result
    end
  end
end
