# Admin Clients Index Request
# Used for listing OAuth clients with pagination
module Authority::Dashboard::Clients
  struct IndexRequest
    include Request

    getter page : Int32 = 1
  end
end
