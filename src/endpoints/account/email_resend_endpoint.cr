# Endpoint for Resending Email Verification
# POST /account/email/resend - Resend verification email
module Authority::Account
  class EmailResendEndpoint
    include Endpoint(EmailResendRequest, EmailVerificationResentResponse)

    post "/account/email/resend"

    def call : EmailVerificationResentResponse
      header "Content-Type", "application/json;charset=UTF-8"
      header "Cache-Control", "no-store"
      header "Pragma", "no-cache"

      # Note: We always return success to prevent email enumeration
      if email_resend_request.valid?
        AccountRecoveryService.resend_email_verification(email_resend_request.email)
        # In production, send email with token here
      end

      EmailVerificationResentResponse.new
    end
  end
end
