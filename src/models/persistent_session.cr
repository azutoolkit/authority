# PersistentSession model for tracking user sessions in the database.
# This allows viewing active sessions and revoking them.
module Authority
  @[Crinja::Attributes(expose: [id_str, user_id, session_token, ip_address, user_agent, device_info, last_activity_at, expires_at, created_at, revoked_at, active, revoked, expired, last_activity_relative])]
  struct PersistentSession
    include CQL::ActiveRecord::Model(UUID)
    include Crinja::Object::Auto
    db_context AuthorityDB, :persistent_sessions

    # Core fields
    property id : UUID = UUID.random
    property user_id : UUID = UUID.random
    property session_token : String = ""
    property ip_address : String?
    property user_agent : String?
    property device_info : String?
    property last_activity_at : Time = Time.utc
    property expires_at : Time = Time.utc
    property created_at : Time = Time.utc
    property revoked_at : Time?

    # Helper to get string ID for templates
    def id_str : String
      id.to_s
    end

    # Check if session is active (not expired and not revoked)
    def active? : Bool
      !revoked? && !expired?
    end

    # Crinja-compatible accessor
    def active : Bool
      active?
    end

    # Check if session is revoked
    def revoked? : Bool
      !revoked_at.nil?
    end

    # Crinja-compatible accessor
    def revoked : Bool
      revoked?
    end

    # Check if session is expired
    def expired? : Bool
      expires_at < Time.utc
    end

    # Crinja-compatible accessor
    def expired : Bool
      expired?
    end

    # Generate a session token
    def self.generate_token : String
      Random::Secure.hex(32)
    end

    # Parse user agent to extract device info
    def self.parse_device_info(user_agent : String?) : String
      return "Unknown Device" unless user_agent

      # Extract browser and OS info
      browser = case user_agent
                when /Firefox/i  then "Firefox"
                when /Chrome/i   then "Chrome"
                when /Safari/i   then "Safari"
                when /Edge/i     then "Edge"
                when /Opera/i    then "Opera"
                when /MSIE|Trident/i then "Internet Explorer"
                else "Unknown Browser"
                end

      os = case user_agent
           when /Windows NT 10/i then "Windows 10"
           when /Windows NT 6\./i then "Windows"
           when /Mac OS X/i then "macOS"
           when /Linux/i then "Linux"
           when /iPhone|iPad/i then "iOS"
           when /Android/i then "Android"
           else "Unknown OS"
           end

      "#{browser} on #{os}"
    end

    # Calculate relative time (e.g., "5 minutes ago")
    def last_activity_relative : String
      diff = Time.utc - last_activity_at
      minutes = diff.total_minutes.to_i
      hours = diff.total_hours.to_i
      days = diff.total_days.to_i

      case
      when minutes < 1  then "just now"
      when minutes < 60 then "#{minutes} minute#{"s" if minutes != 1} ago"
      when hours < 24   then "#{hours} hour#{"s" if hours != 1} ago"
      when days < 7     then "#{days} day#{"s" if days != 1} ago"
      else              last_activity_at.to_s("%Y-%m-%d %H:%M")
      end
    end

    # Check if this might be the current session based on IP/UA
    def likely_current?(current_ip : String?, current_ua : String?) : Bool
      ip_match = ip_address == current_ip
      ua_match = user_agent == current_ua
      ip_match && ua_match
    end
  end
end
