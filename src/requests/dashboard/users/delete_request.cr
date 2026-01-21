# Admin Users Delete Request
module Authority::Dashboard::Users
  struct DeleteRequest
    include Request

    getter id : String
  end
end
