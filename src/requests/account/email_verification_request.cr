# Email Verification Request
# Used to verify email with token
module Authority::Account
  struct EmailVerificationRequest
    include Request

    getter token : String

    validate token, message: "Token is required", presence: true
  end
end
