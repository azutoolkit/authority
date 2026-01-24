# Account Recovery Response
# JSON responses for account recovery endpoints
module Authority
  # Generic success response
  struct AccountRecoveryResponse
    include Response

    getter? success : Bool
    getter message : String

    def initialize(@success : Bool = true, @message : String = "")
    end

    def render
      {success: @success, message: @message}.to_json
    end
  end

  # Password reset initiated response
  # Note: Always returns success to prevent email enumeration
  struct PasswordResetInitiatedResponse
    include Response

    def initialize
    end

    def render
      {
        success: true,
        message: "If an account with that email exists, a password reset link has been sent.",
      }.to_json
    end
  end

  # Password reset completed response
  struct PasswordResetCompletedResponse
    include Response

    def initialize
    end

    def render
      {
        success: true,
        message: "Password has been reset successfully.",
      }.to_json
    end
  end

  # Email verification completed response
  struct EmailVerificationCompletedResponse
    include Response

    def initialize
    end

    def render
      {
        success: true,
        message: "Email has been verified successfully.",
      }.to_json
    end
  end

  # Email verification resent response
  # Note: Always returns success to prevent email enumeration
  struct EmailVerificationResentResponse
    include Response

    def initialize
    end

    def render
      {
        success: true,
        message: "If an account with that email exists and is not yet verified, a verification link has been sent.",
      }.to_json
    end
  end

  # Token validation response
  struct TokenValidationResponse
    include Response

    getter? valid : Bool

    def initialize(@valid : Bool)
    end

    def render
      {valid: @valid}.to_json
    end
  end

  # Error response for account recovery
  struct AccountRecoveryErrorResponse
    include Response

    getter error : String
    getter error_description : String

    def initialize(@error : String, @error_description : String = "")
    end

    def render
      {error: @error, error_description: @error_description}.to_json
    end
  end
end
