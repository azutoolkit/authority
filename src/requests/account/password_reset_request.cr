# Password Reset Request
# Used to initiate password reset flow
module Authority::Account
  struct PasswordResetRequest
    include Request

    getter email : String

    validate email, message: "Email is required", presence: true
  end
end
