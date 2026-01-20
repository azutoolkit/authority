# Account Recovery Service
# Handles password reset and email verification flows
module Authority
  class AccountRecoveryService
    # Request a password reset for an email address
    # Returns the token (for email sending) or nil if user not found
    # Note: Always return success to prevent email enumeration attacks
    def self.request_password_reset(email : String) : RecoveryToken?
      user = User.find_by(email: email)
      return nil unless user

      RecoveryToken.create_password_reset(user.id!.to_s)
    end

    # Confirm password reset with token and new password
    def self.confirm_password_reset(token : String, new_password : String) : User
      RecoveryToken.complete_password_reset!(token, new_password)
    end

    # Request email verification for a user
    def self.request_email_verification(user_id : String) : RecoveryToken?
      user = User.find(user_id)
      return nil unless user
      return nil if user.email_verified # Already verified

      RecoveryToken.create_email_verification(user_id)
    end

    # Confirm email verification with token
    def self.confirm_email_verification(token : String) : User
      RecoveryToken.complete_email_verification!(token)
    end

    # Check if a password reset token is valid
    def self.valid_password_reset_token?(token : String) : Bool
      RecoveryToken.find_valid(token, RecoveryToken::PASSWORD_RESET) != nil
    end

    # Check if an email verification token is valid
    def self.valid_email_verification_token?(token : String) : Bool
      RecoveryToken.find_valid(token, RecoveryToken::EMAIL_VERIFICATION) != nil
    end

    # Get user from password reset token (for pre-populating forms)
    def self.user_from_password_reset_token(token : String) : User?
      RecoveryToken.verify_password_reset(token)
    end

    # Resend email verification for a user by email
    def self.resend_email_verification(email : String) : RecoveryToken?
      user = User.find_by(email: email)
      return nil unless user
      return nil if user.email_verified # Already verified

      RecoveryToken.create_email_verification(user.id!.to_s)
    end
  end
end
