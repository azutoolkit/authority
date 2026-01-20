# Endpoint for Reset Password page
# GET /reset-password - Display the reset password form
# POST /reset-password - Process the new password
module Authority::Account
  RESET_PASSWORD_PATH = "/reset-password"

  # GET /reset-password - Show the reset password form
  class ResetPasswordShowEndpoint
    include SecurityHeadersHelper
    include Endpoint(PasswordResetConfirmRequest, ResetPasswordFormResponse | ErrorResponse)

    get RESET_PASSWORD_PATH

    def call : ResetPasswordFormResponse | ErrorResponse
      set_security_headers!
      header "Content-Type", "text/html; charset=UTF-8"
      header "Cache-Control", "no-store"
      header "Pragma", "no-cache"

      token = params["token"]?

      if token.nil? || token.empty?
        status 400
        return ErrorResponse.new(400, "Invalid Request", "Missing password reset token")
      end

      # Validate that the token exists and is valid
      unless AccountRecoveryService.valid_password_reset_token?(token)
        status 400
        return ErrorResponse.new(400, "Invalid Token", "This password reset link is invalid or has expired.")
      end

      ResetPasswordFormResponse.new(token)
    end
  end

  # POST /reset-password - Process the new password
  class ResetPasswordCreateEndpoint
    include SecurityHeadersHelper
    include Endpoint(PasswordResetConfirmRequest, ResetPasswordFormResponse | ResetPasswordSuccessResponse | ErrorResponse)

    post RESET_PASSWORD_PATH

    def call : ResetPasswordFormResponse | ResetPasswordSuccessResponse | ErrorResponse
      set_security_headers!
      header "Content-Type", "text/html; charset=UTF-8"
      header "Cache-Control", "no-store"
      header "Pragma", "no-cache"

      unless password_reset_confirm_request.valid?
        status 400
        return ResetPasswordFormResponse.new(
          password_reset_confirm_request.token,
          password_reset_confirm_request.errors.map(&.message)
        )
      end

      # Verify passwords match
      if password_reset_confirm_request.password != password_reset_confirm_request.confirm_password
        status 400
        return ResetPasswordFormResponse.new(
          password_reset_confirm_request.token,
          ["Passwords do not match"]
        )
      end

      begin
        AccountRecoveryService.confirm_password_reset(
          password_reset_confirm_request.token,
          password_reset_confirm_request.password
        )
        ResetPasswordSuccessResponse.new
      rescue ex
        status 400
        ErrorResponse.new(400, "Reset Failed", "This password reset link is invalid or has expired.")
      end
    end
  end
end
