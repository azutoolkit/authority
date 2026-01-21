# Authorization Code Single-Use Service
# Enforces single-use of authorization codes per OAuth 2.0 spec (RFC 6749 Section 4.1.2).
# Tracks used codes and detects reuse attempts for security alerting.
require "digest/sha256"

module Authority
  module AuthCodeSingleUseService
    # Check if an authorization code has been used.
    #
    # @param code [String] The authorization code
    # @return [Bool] True if the code has been used
    def self.used?(code : String) : Bool
      code_hash = hash_code(code)
      UsedAuthCode.used?(code_hash)
    rescue
      false
    end

    # Mark an authorization code as used.
    #
    # @param code [String] The authorization code
    # @param client_id [String] The client that used the code
    # @return [Bool] True if successfully marked
    def self.mark_used(code : String, client_id : String) : Bool
      code_hash = hash_code(code)
      UsedAuthCode.mark_used!(code_hash, client_id)
    end

    # Try to use an authorization code (atomic check-and-mark).
    # Returns success status and whether reuse was detected.
    #
    # @param code [String] The authorization code
    # @param client_id [String] The client attempting to use the code
    # @return [NamedTuple] {success: Bool, reuse_detected: Bool}
    def self.try_use(code : String, client_id : String) : NamedTuple(success: Bool, reuse_detected: Bool)
      code_hash = hash_code(code)
      UsedAuthCode.try_use(code_hash, client_id)
    end

    # Clean up expired authorization codes from the tracking table.
    # Should be called periodically to prevent table bloat.
    #
    # @param max_age [Time::Span] Maximum age of entries to keep (default: 10 minutes)
    def self.cleanup_expired(max_age : Time::Span = 10.minutes) : Int64
      UsedAuthCode.cleanup_expired!(max_age)
    rescue
      0_i64
    end

    # Hash the authorization code for storage.
    # We don't store the actual code for security reasons.
    private def self.hash_code(code : String) : String
      Digest::SHA256.hexdigest(code)
    end
  end
end
