# Endpoint for Password Reset Request
# POST /account/password/reset - Initiate password reset flow
module Authority::Account
  class PasswordResetRequestEndpoint
    include Endpoint(PasswordResetRequest, PasswordResetInitiatedResponse)

    post "/account/password/reset"

    def call : PasswordResetInitiatedResponse
      header "Content-Type", "application/json;charset=UTF-8"
      header "Cache-Control", "no-store"
      header "Pragma", "no-cache"

      # Note: We always return success to prevent email enumeration
      # The service handles the case where user doesn't exist
      if password_reset_request.valid?
        AccountRecoveryService.request_password_reset(password_reset_request.email)
        # In production, send email with token here
      end

      PasswordResetInitiatedResponse.new
    end
  end
end
