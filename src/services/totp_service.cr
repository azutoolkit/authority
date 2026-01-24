require "openssl/hmac"
require "base64"

# TOTP Service (Time-based One-Time Password)
# Implements RFC 6238 for multi-factor authentication.
module Authority
  module TOTPService
    extend self

    # TOTP configuration
    DIGITS      =  6    # Number of digits in the code
    PERIOD      = 30    # Time period in seconds
    ALGORITHM   = :sha1 # HMAC algorithm
    ISSUER      = "Authority"
    SECRET_SIZE = 20 # 160 bits as recommended by RFC 4226

    # Result struct for TOTP operations
    struct SetupResult
      getter? success : Bool
      getter secret : String?
      getter qr_uri : String?
      getter backup_codes : Array(String)?
      getter error : String?

      def initialize(
        @success : Bool,
        @secret : String? = nil,
        @qr_uri : String? = nil,
        @backup_codes : Array(String)? = nil,
        @error : String? = nil
      )
      end
    end

    struct VerifyResult
      getter? success : Bool
      getter? backup_code_used : Bool
      getter error : String?

      def initialize(@success : Bool, @backup_code_used : Bool = false, @error : String? = nil)
      end
    end

    # Generate a new TOTP secret for a user
    def generate_secret : String
      # Generate random bytes and encode as Base32
      random_bytes = Random::Secure.random_bytes(SECRET_SIZE)
      base32_encode(random_bytes)
    end

    # Generate the provisioning URI for QR code (otpauth://totp/...)
    def generate_qr_uri(secret : String, user_email : String) : String
      # URL encode the email and issuer
      encoded_email = URI.encode_www_form(user_email)
      encoded_issuer = URI.encode_www_form(ISSUER)

      "otpauth://totp/#{encoded_issuer}:#{encoded_email}?secret=#{secret}&issuer=#{encoded_issuer}&algorithm=SHA1&digits=#{DIGITS}&period=#{PERIOD}"
    end

    # Generate backup codes for recovery
    def generate_backup_codes(count : Int32 = 10) : Array(String)
      count.times.map do
        # Generate 8 random alphanumeric characters
        chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        code = String.build do |str|
          8.times { str << chars[Random::Secure.rand(chars.size)] }
        end
        # Format as XXXX-XXXX
        "#{code[0, 4]}-#{code[4, 4]}"
      end.to_a
    end

    # Setup MFA for a user
    def setup(user : User) : SetupResult
      return SetupResult.new(success: false, error: "User already has MFA enabled") if user.mfa_enabled

      secret = generate_secret
      qr_uri = generate_qr_uri(secret, user.email)
      backup_codes = generate_backup_codes

      SetupResult.new(
        success: true,
        secret: secret,
        qr_uri: qr_uri,
        backup_codes: backup_codes
      )
    end

    # Verify a TOTP code
    def verify(code : String, secret : String, window : Int32 = 1) : Bool
      return false if code.empty? || secret.empty?

      # Clean the code (remove spaces and dashes)
      clean_code = code.gsub(/[\s\-]/, "")

      # Check current time step and adjacent time steps (for clock drift)
      current_time = Time.utc.to_unix
      (-window..window).each do |offset|
        time_step = (current_time // PERIOD) + offset
        expected_code = generate_code(secret, time_step)
        return true if secure_compare(clean_code, expected_code)
      end

      false
    end

    # Verify a backup code
    def verify_backup_code(code : String, user : User) : VerifyResult
      backup_codes = user.backup_codes
      return VerifyResult.new(success: false, error: "No backup codes available") if backup_codes.nil?

      begin
        codes = Array(String).from_json(backup_codes)
        clean_code = code.upcase.gsub(/[\s\-]/, "")
        clean_code = "#{clean_code[0, 4]}-#{clean_code[4, 4]}" if clean_code.size == 8

        if codes.includes?(clean_code)
          # Remove used backup code
          codes.delete(clean_code)

          # Update user's backup codes
          user.backup_codes = codes.to_json
          user.updated_at = Time.utc
          user.update!

          return VerifyResult.new(success: true, backup_code_used: true)
        end
      rescue
        # Invalid JSON or other error
      end

      VerifyResult.new(success: false, error: "Invalid backup code")
    end

    # Complete MFA setup for a user
    def enable(user : User, secret : String, backup_codes : Array(String), verification_code : String) : VerifyResult
      # Verify the code first
      unless verify(verification_code, secret)
        return VerifyResult.new(success: false, error: "Invalid verification code")
      end

      # Encrypt and store the secret
      user.totp_secret = encrypt_secret(secret)
      user.backup_codes = backup_codes.to_json
      user.mfa_enabled = true
      user.updated_at = Time.utc
      user.update!

      VerifyResult.new(success: true)
    end

    # Disable MFA for a user
    def disable(user : User) : VerifyResult
      return VerifyResult.new(success: false, error: "MFA is not enabled") unless user.mfa_enabled?

      user.totp_secret = nil
      user.backup_codes = nil
      user.mfa_enabled = false
      user.updated_at = Time.utc
      user.update!

      VerifyResult.new(success: true)
    end

    # Verify MFA code for a user (handles both TOTP and backup codes)
    def verify_user_code(user : User, code : String) : VerifyResult
      return VerifyResult.new(success: false, error: "MFA is not enabled") unless user.mfa_enabled?

      totp_secret = user.totp_secret
      return VerifyResult.new(success: false, error: "No TOTP secret configured") if totp_secret.nil?

      # Try TOTP code first
      secret = decrypt_secret(totp_secret)
      if verify(code, secret)
        return VerifyResult.new(success: true)
      end

      # Try backup code
      verify_backup_code(code, user)
    end

    # Get remaining backup codes count
    def backup_codes_remaining(user : User) : Int32
      if backup_codes = user.backup_codes
        begin
          Array(String).from_json(backup_codes).size
        rescue
          0
        end
      else
        0
      end
    end

    # Generate a TOTP code for a given time step
    private def generate_code(secret : String, time_step : Int64) : String
      # Decode the Base32 secret
      key = base32_decode(secret)

      # Convert time step to 8-byte big-endian
      message = Bytes.new(8)
      7.downto(0) do |i|
        message[i] = (time_step & 0xFF).to_u8
        time_step >>= 8
      end

      # Calculate HMAC-SHA1
      hmac = OpenSSL::HMAC.digest(:sha1, key, message)

      # Dynamic truncation
      offset = (hmac[hmac.size - 1] & 0x0F).to_i
      binary = ((hmac[offset].to_i & 0x7F) << 24) |
               ((hmac[offset + 1].to_i & 0xFF) << 16) |
               ((hmac[offset + 2].to_i & 0xFF) << 8) |
               (hmac[offset + 3].to_i & 0xFF)

      # Get the last DIGITS digits
      code = binary % (10 ** DIGITS)
      code.to_s.rjust(DIGITS, '0')
    end

    # Base32 encoding (RFC 4648)
    private def base32_encode(bytes : Bytes) : String
      alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
      bits = 0
      value = 0
      result = String::Builder.new

      bytes.each do |byte|
        value = (value << 8) | byte
        bits += 8

        while bits >= 5
          result << alphabet[(value >> (bits - 5)) & 31]
          bits -= 5
        end
      end

      if bits > 0
        result << alphabet[(value << (5 - bits)) & 31]
      end

      result.to_s
    end

    # Base32 decoding (RFC 4648)
    private def base32_decode(str : String) : Bytes
      alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
      output = IO::Memory.new
      bits = 0
      value = 0

      str.upcase.each_char do |char|
        next if char == '='
        idx = alphabet.index(char)
        next unless idx

        value = (value << 5) | idx
        bits += 5

        if bits >= 8
          output.write_byte((value >> (bits - 8)).to_u8)
          bits -= 8
        end
      end

      output.to_slice
    end

    # Encrypt secret for storage (simple XOR with app secret, should use proper encryption in production)
    private def encrypt_secret(secret : String) : String
      # In production, use proper AES encryption
      # For now, we'll store it Base64 encoded (should be encrypted!)
      Base64.strict_encode(secret)
    end

    # Decrypt secret from storage
    private def decrypt_secret(encrypted : String) : String
      # In production, use proper AES decryption
      Base64.decode_string(encrypted)
    end

    # Constant-time string comparison to prevent timing attacks
    private def secure_compare(a : String, b : String) : Bool
      return false unless a.size == b.size

      result = 0
      a.each_char_with_index do |char, i|
        result |= char.ord ^ b[i].ord
      end

      result == 0
    end
  end
end
