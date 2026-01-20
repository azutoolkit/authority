# Password Reset Confirm Request
# Used to complete password reset with new password
module Authority::Account
  struct PasswordResetConfirmRequest
    include Request

    getter token : String
    getter password : String
    getter confirm_password : String

    use ConfirmPasswordValidator

    validate token, message: "Token is required", presence: true
    validate password, message: "Password is required", presence: true
  end
end
