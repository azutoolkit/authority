# Email Resend Request
# Used to resend email verification
module Authority::Account
  struct EmailResendRequest
    include Request

    getter email : String

    validate email, message: "Email is required", presence: true
  end
end
