# Admin Scopes Show Request
module Authority::Dashboard::Scopes
  struct ShowRequest
    include Request

    getter id : String
  end
end
