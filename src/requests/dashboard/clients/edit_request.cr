# Admin Client Edit Request
# Used for displaying the edit form
module Authority::Dashboard::Clients
  struct EditRequest
    include Request

    getter id : String = ""
  end
end
