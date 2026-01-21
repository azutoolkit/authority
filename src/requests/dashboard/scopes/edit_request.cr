# Admin Scopes Edit Request
module Authority::Dashboard::Scopes
  struct EditRequest
    include Request

    getter id : String
  end
end
