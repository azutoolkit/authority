# Admin Users Unlock Request
module Authority::Dashboard::Users
  struct UnlockRequest
    include Request

    getter id : String
  end
end
