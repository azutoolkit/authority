# Admin Client Show Request
# Used for displaying client details
module Authority::Dashboard::Clients
  struct ShowRequest
    include Request

    getter id : String = ""
  end
end
