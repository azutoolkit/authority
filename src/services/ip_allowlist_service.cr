# IP Allowlist Service
# Restricts admin access to specific IP addresses or CIDR ranges.
# Uses ADMIN_ALLOWED_IPS environment variable.
module Authority
  module IPAllowlistService
    # Environment variable name for allowed IPs
    ENV_VAR = "ADMIN_ALLOWED_IPS"

    # Represents a CIDR range for matching
    struct CIDRRange
      getter network : UInt32
      getter mask : UInt32

      def initialize(cidr : String)
        parts = cidr.split("/")
        ip_str = parts[0]
        prefix = parts[1]?.try(&.to_i) || 32

        @network = ip_to_int(ip_str)
        @mask = prefix == 0 ? 0_u32 : (~0_u32) << (32 - prefix)
        @network = @network & @mask # Normalize network address
      end

      def includes?(ip : String) : Bool
        ip_int = ip_to_int(ip)
        (ip_int & @mask) == @network
      end

      private def ip_to_int(ip : String) : UInt32
        parts = ip.split(".").map(&.to_u32)
        (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8) | parts[3]
      end
    end

    # Cache parsed allowlist entries
    @@entries : Array(String | CIDRRange)?

    # Check if an IP address is allowed to access admin functionality
    # Returns true if:
    # - ADMIN_ALLOWED_IPS is not set or empty (allow all)
    # - IP matches one of the allowed IPs or CIDR ranges
    def self.allowed?(ip : String) : Bool
      entries = entries()
      return true if entries.empty? # No restriction if not configured

      # Normalize IP (handle IPv6-mapped IPv4 like ::ffff:192.168.1.1)
      normalized_ip = normalize_ip(ip)
      return false if normalized_ip.nil?

      entries.any? do |entry|
        case entry
        when String
          entry == normalized_ip
        when CIDRRange
          entry.includes?(normalized_ip)
        else
          false
        end
      end
    rescue
      false # Invalid IP format, deny access
    end

    # Check if allowlist is configured
    def self.configured? : Bool
      env_value = ENV[ENV_VAR]?
      !env_value.nil? && !env_value.empty?
    end

    # Get the raw allowlist configuration
    def self.raw_config : String?
      ENV[ENV_VAR]?
    end

    # Clear cached entries (for testing)
    def self.clear_cache : Nil
      @@entries = nil
    end

    # Parse and cache entries from environment
    private def self.entries : Array(String | CIDRRange)
      @@entries ||= parse_config(ENV[ENV_VAR]?)
    end

    # Parse config string into array of IPs/CIDRs
    private def self.parse_config(config : String?) : Array(String | CIDRRange)
      return [] of String | CIDRRange if config.nil? || config.empty?

      config.split(/[,\s]+/).compact_map do |entry|
        entry = entry.strip
        next nil if entry.empty?

        if entry.includes?("/")
          # CIDR notation - only support IPv4 for simplicity
          begin
            CIDRRange.new(entry)
          rescue
            nil # Skip invalid CIDR
          end
        else
          # Single IP address - normalize it
          normalize_ip(entry)
        end
      end
    end

    # Normalize IP address for comparison
    # Handles IPv6-mapped IPv4 addresses
    private def self.normalize_ip(ip : String) : String?
      ip = ip.strip

      # Handle IPv6-mapped IPv4 (::ffff:192.168.1.1)
      if ip.starts_with?("::ffff:")
        ip = ip[7..]
      end

      # Remove brackets from IPv6
      ip = ip.gsub(/^\[|\]$/, "")

      # Skip IPv6 addresses (only support IPv4 for now)
      return nil if ip.includes?(":")

      # Validate IPv4 format
      parts = ip.split(".")
      return nil unless parts.size == 4
      return nil unless parts.all? { |part| part.to_i?.try { |num| num >= 0 && num <= 255 } }

      ip
    end
  end
end
