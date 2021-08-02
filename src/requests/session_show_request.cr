# Request Docs https://azutopia.gitbook.io/azu/endpoints/requests
module Authority
  struct SessionShowRequest
    include Request

    getter forward_url : String = "/user-info"
    validate forward_url, message: "Param forward_url must be present.", presence: false
  end
end
