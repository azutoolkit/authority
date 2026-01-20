# CSRF Token Service
# Generates and validates CSRF tokens for form submissions.
# Uses cryptographically secure random generation and timing-safe comparison.
module Authority
  module CSRFService
    # Generates a new CSRF token.
    # Returns a 64-character hexadecimal string (256 bits of entropy).
    def self.generate_token : String
      Random::Secure.hex(32)
    end

    # Validates that the request token matches the session token.
    # Uses timing-safe comparison to prevent timing attacks.
    #
    # @param session_token [String?] The token stored in the session
    # @param request_token [String?] The token submitted with the request
    # @return [Bool] True if tokens match and are valid
    def self.valid?(session_token : String?, request_token : String?) : Bool
      return false if session_token.nil? || request_token.nil?
      return false if session_token.empty? || request_token.empty?

      # Use timing-safe comparison
      SecureCompare.secure_compare(session_token, request_token)
    end
  end
end
