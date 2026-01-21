# Admin Users Show Request
module Authority::Dashboard::Users
  struct ShowRequest
    include Request

    getter id : String
  end
end
