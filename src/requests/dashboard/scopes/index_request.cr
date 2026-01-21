# Admin Scopes Index Request
module Authority::Dashboard::Scopes
  struct IndexRequest
    include Request

    getter page : Int32 = 1
  end
end
