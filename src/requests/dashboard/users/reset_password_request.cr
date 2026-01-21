# Admin Users Reset Password Request
module Authority::Dashboard::Users
  struct ResetPasswordRequest
    include Request

    getter id : String
    getter password : String = ""
  end
end
