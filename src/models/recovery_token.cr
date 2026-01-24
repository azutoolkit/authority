# Recovery Token Model
# Handles password reset and email verification tokens
# Tokens are single-use and time-limited for security
module Authority
  class RecoveryToken
    include CQL::ActiveRecord::Model(UUID)
    db_context AuthorityDB, :oauth_recovery_tokens

    # Token types
    PASSWORD_RESET     = "password_reset"
    EMAIL_VERIFICATION = "email_verification"

    # TTL for different token types
    PASSWORD_RESET_TTL     = 1.hour
    EMAIL_VERIFICATION_TTL = 24.hours

    TOKEN_LENGTH = 32 # 128 bits of entropy

    property token : String = ""
    property token_type : String = "password_reset"
    property user_id : String = ""
    property expires_at : Time = Time.utc
    property used_at : Time?
    property created_at : Time?
    property updated_at : Time?

    before_save :generate_token

    def initialize
    end

    private def generate_token
      @token = Random::Secure.hex(TOKEN_LENGTH) if @token.empty?
      true
    end

    # Check if token is valid (not expired and not used)
    def valid_token? : Bool
      !expired? && !used?
    end

    # Check if token is expired
    def expired? : Bool
      Time.utc > expires_at
    end

    # Check if token has been used
    def used? : Bool
      !used_at.nil?
    end

    # Mark token as used
    def mark_used!
      @used_at = Time.utc
      update!
    end

    # Create a password reset token for a user
    def self.create_password_reset(user_id : String) : RecoveryToken
      # Invalidate any existing password reset tokens for this user
      invalidate_tokens_for_user!(user_id, PASSWORD_RESET)

      token = RecoveryToken.new
      token.token_type = PASSWORD_RESET
      token.user_id = user_id
      token.expires_at = PASSWORD_RESET_TTL.from_now
      token.save!
      token
    end

    # Create an email verification token for a user
    def self.create_email_verification(user_id : String) : RecoveryToken
      # Invalidate any existing email verification tokens for this user
      invalidate_tokens_for_user!(user_id, EMAIL_VERIFICATION)

      token = RecoveryToken.new
      token.token_type = EMAIL_VERIFICATION
      token.user_id = user_id
      token.expires_at = EMAIL_VERIFICATION_TTL.from_now
      token.save!
      token
    end

    # Find a valid token by its string value
    def self.find_valid(token_string : String, token_type : String) : RecoveryToken?
      token = find_by(token: token_string, token_type: token_type)
      return nil unless token
      return nil if token.expired?
      return nil if token.used?
      token
    end

    # Find a valid token, raise if not found
    def self.find_valid!(token_string : String, token_type : String) : RecoveryToken
      find_valid(token_string, token_type) || raise "Invalid or expired token"
    end

    # Invalidate all tokens of a type for a user
    def self.invalidate_tokens_for_user!(user_id : String, token_type : String)
      where(user_id: user_id, token_type: token_type).each do |token|
        token.mark_used! unless token.used?
      end
    end

    # Cleanup expired tokens (for maintenance)
    def self.cleanup_expired!
      RecoveryToken
        .where { oauth_recovery_tokens.expires_at < Time.utc }
        .delete_all
    end

    # Verify a password reset token and return the user
    def self.verify_password_reset(token_string : String) : User?
      token = find_valid(token_string, PASSWORD_RESET)
      return nil unless token

      User.find_by(id: token.user_id)
    end

    # Verify an email verification token and return the user
    def self.verify_email_verification(token_string : String) : User?
      token = find_valid(token_string, EMAIL_VERIFICATION)
      return nil unless token

      User.find_by(id: token.user_id)
    end

    # Complete password reset - verify token, update password, mark token used
    def self.complete_password_reset!(token_string : String, new_password : String) : User
      token = find_valid!(token_string, PASSWORD_RESET)
      user = User.find_by!(id: token.user_id)

      user.password = new_password
      user.save!

      token.mark_used!
      user
    end

    # Complete email verification - verify token, mark email verified, mark token used
    def self.complete_email_verification!(token_string : String) : User
      token = find_valid!(token_string, EMAIL_VERIFICATION)
      user = User.find_by!(id: token.user_id)

      user.email_verified = true
      user.save!

      token.mark_used!
      user
    end
  end
end
