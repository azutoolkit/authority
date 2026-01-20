# Endpoint for Password Reset Confirmation
# POST /account/password/confirm - Complete password reset with new password
module Authority::Account
  class PasswordResetConfirmEndpoint
    include Endpoint(PasswordResetConfirmRequest, PasswordResetCompletedResponse | AccountRecoveryErrorResponse)

    post "/account/password/confirm"

    def call : PasswordResetCompletedResponse | AccountRecoveryErrorResponse
      header "Content-Type", "application/json;charset=UTF-8"
      header "Cache-Control", "no-store"
      header "Pragma", "no-cache"

      unless password_reset_confirm_request.valid?
        status 400
        return AccountRecoveryErrorResponse.new(
          "invalid_request",
          password_reset_confirm_request.errors.map(&.message).join(", ")
        )
      end

      AccountRecoveryService.confirm_password_reset(
        password_reset_confirm_request.token,
        password_reset_confirm_request.password
      )

      PasswordResetCompletedResponse.new
    rescue ex
      status 400
      AccountRecoveryErrorResponse.new("invalid_token", "Invalid or expired token")
    end
  end
end
