# Request Docs https://azutopia.gitbook.io/azu/endpoints/requests
module Authority
  struct SessionShowRequest
    include Request

    getter forward_url : String = Base64.urlsafe_encode("/user-info")
  end
end
