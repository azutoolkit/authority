module Authority::Clients
  struct ShowRequest
    include Request

    getter id : String

    validate name, message: "Param client id is required.", presence: true
  end
end
