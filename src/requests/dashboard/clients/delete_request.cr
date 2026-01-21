# Admin Client Delete Request
# Used for deleting an OAuth client
module Authority::Dashboard::Clients
  struct DeleteRequest
    include Request

    getter id : String = ""
  end
end
