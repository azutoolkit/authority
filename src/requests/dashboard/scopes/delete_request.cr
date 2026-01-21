# Admin Scopes Delete Request
module Authority::Dashboard::Scopes
  struct DeleteRequest
    include Request

    getter id : String
  end
end
