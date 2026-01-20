# Endpoint for Forgot Password page
# GET /forgot-password - Display the forgot password form
# POST /forgot-password - Process the forgot password request
module Authority::Account
  FORGOT_PASSWORD_PATH = "/forgot-password"

  # GET /forgot-password - Show the forgot password form
  class ForgotPasswordShowEndpoint
    include SecurityHeadersHelper
    include Endpoint(PasswordResetRequest, ForgotPasswordFormResponse)

    get FORGOT_PASSWORD_PATH

    def call : ForgotPasswordFormResponse
      set_security_headers!
      header "Content-Type", "text/html; charset=UTF-8"
      header "Cache-Control", "no-store"
      header "Pragma", "no-cache"

      ForgotPasswordFormResponse.new
    end
  end

  # POST /forgot-password - Process the forgot password request
  class ForgotPasswordCreateEndpoint
    include SecurityHeadersHelper
    include Endpoint(PasswordResetRequest, ForgotPasswordFormResponse | ForgotPasswordSentResponse)

    post FORGOT_PASSWORD_PATH

    def call : ForgotPasswordFormResponse | ForgotPasswordSentResponse
      set_security_headers!
      header "Content-Type", "text/html; charset=UTF-8"
      header "Cache-Control", "no-store"
      header "Pragma", "no-cache"

      unless password_reset_request.valid?
        status 400
        return ForgotPasswordFormResponse.new(
          password_reset_request.email,
          password_reset_request.errors.map(&.message)
        )
      end

      # Initiate password reset (always succeeds to prevent email enumeration)
      AccountRecoveryService.request_password_reset(password_reset_request.email)

      ForgotPasswordSentResponse.new(password_reset_request.email)
    end
  end
end
