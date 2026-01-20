# Timing-Safe String Comparison
# Provides constant-time string comparison to prevent timing attacks.
# Use this for comparing secrets like passwords, tokens, and API keys.
module Authority
  module SecureCompare
    # Performs a constant-time comparison of two strings.
    # Returns true if the strings are equal, false otherwise.
    #
    # This method is designed to prevent timing attacks by ensuring
    # the comparison takes the same amount of time regardless of
    # where the strings differ.
    #
    # @param a [String] First string to compare
    # @param b [String] Second string to compare
    # @return [Bool] true if strings are equal, false otherwise
    def self.secure_compare(a : String, b : String) : Bool
      # Early return for different lengths, but still constant-time
      # for the comparison of bytes
      return false if a.bytesize != b.bytesize

      # XOR each byte and accumulate differences
      # This runs in O(n) time regardless of where differences occur
      result = 0_u8
      a.bytes.zip(b.bytes) do |x, y|
        result |= x ^ y
      end

      result == 0
    end
  end
end
