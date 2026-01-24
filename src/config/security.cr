# Security configuration for authentication and account protection
module Authority
  class Security
    # Account lockout settings
    class_property lockout_threshold : Int32 = ENV.fetch("LOCKOUT_THRESHOLD", "5").to_i
    class_property lockout_duration : Time::Span = ENV.fetch("LOCKOUT_DURATION_MINUTES", "30").to_i.minutes
    class_property? auto_unlock_enabled : Bool = ENV.fetch("AUTO_UNLOCK_ENABLED", "true") == "true"

    # Progressive delay settings (in seconds)
    class_property? progressive_delay_enabled : Bool = ENV.fetch("PROGRESSIVE_DELAY_ENABLED", "true") == "true"
    class_property progressive_delay_base : Int32 = ENV.fetch("PROGRESSIVE_DELAY_BASE", "1").to_i
    class_property progressive_delay_max : Int32 = ENV.fetch("PROGRESSIVE_DELAY_MAX", "30").to_i

    # Password policy settings
    class_property password_min_length : Int32 = ENV.fetch("PASSWORD_MIN_LENGTH", "12").to_i
    class_property? password_require_uppercase : Bool = ENV.fetch("PASSWORD_REQUIRE_UPPERCASE", "true") == "true"
    class_property? password_require_lowercase : Bool = ENV.fetch("PASSWORD_REQUIRE_LOWERCASE", "true") == "true"
    class_property? password_require_number : Bool = ENV.fetch("PASSWORD_REQUIRE_NUMBER", "true") == "true"
    class_property? password_require_special : Bool = ENV.fetch("PASSWORD_REQUIRE_SPECIAL", "true") == "true"
    class_property password_history_count : Int32 = ENV.fetch("PASSWORD_HISTORY_COUNT", "5").to_i
    class_property password_expiry_days : Int32 = ENV.fetch("PASSWORD_EXPIRY_DAYS", "0").to_i # 0 = disabled

    # Session security
    class_property session_absolute_timeout : Time::Span = ENV.fetch("SESSION_ABSOLUTE_TIMEOUT_HOURS", "24").to_i.hours
    class_property session_idle_timeout : Time::Span = ENV.fetch("SESSION_IDLE_TIMEOUT_MINUTES", "60").to_i.minutes

    # Rate limiting
    class_property? rate_limit_enabled : Bool = ENV.fetch("RATE_LIMIT_ENABLED", "true") == "true"
    class_property rate_limit_requests_per_minute : Int32 = ENV.fetch("RATE_LIMIT_REQUESTS_PER_MINUTE", "60").to_i

    # Calculate progressive delay based on failed attempts
    def self.calculate_delay(failed_attempts : Int32) : Time::Span
      return Time::Span.zero unless progressive_delay_enabled?
      return Time::Span.zero if failed_attempts <= 0

      # Exponential backoff: base * 2^(attempts-1), capped at max
      delay_seconds = [progressive_delay_base * (2 ** (failed_attempts - 1)), progressive_delay_max].min
      delay_seconds.seconds
    end

    # Check if account should be auto-unlocked based on time elapsed
    def self.should_auto_unlock?(locked_at : Time?) : Bool
      return false unless auto_unlock_enabled?

      if lock_time = locked_at
        Time.utc - lock_time >= lockout_duration
      else
        false
      end
    end

    # Check if account should be locked based on failed attempts
    def self.should_lock?(failed_attempts : Int32) : Bool
      failed_attempts >= lockout_threshold
    end
  end
end
