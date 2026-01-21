# Admin Users Lock Request
module Authority::Dashboard::Users
  struct LockRequest
    include Request

    getter id : String
    getter reason : String = ""
  end
end
