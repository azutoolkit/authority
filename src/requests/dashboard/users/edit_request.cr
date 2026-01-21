# Admin Users Edit Request
module Authority::Dashboard::Users
  struct EditRequest
    include Request

    getter id : String
  end
end
