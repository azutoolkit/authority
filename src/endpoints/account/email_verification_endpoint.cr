# Endpoint for Email Verification
# POST /account/email/verify - Verify email address with token
module Authority::Account
  class EmailVerificationEndpoint
    include Endpoint(EmailVerificationRequest, EmailVerificationCompletedResponse | AccountRecoveryErrorResponse)

    post "/account/email/verify"

    def call : EmailVerificationCompletedResponse | AccountRecoveryErrorResponse
      header "Content-Type", "application/json;charset=UTF-8"
      header "Cache-Control", "no-store"
      header "Pragma", "no-cache"

      unless email_verification_request.valid?
        status 400
        return AccountRecoveryErrorResponse.new(
          "invalid_request",
          email_verification_request.errors.map(&.message).join(", ")
        )
      end

      AccountRecoveryService.confirm_email_verification(email_verification_request.token)

      EmailVerificationCompletedResponse.new
    rescue ex
      status 400
      AccountRecoveryErrorResponse.new("invalid_token", "Invalid or expired token")
    end
  end
end
