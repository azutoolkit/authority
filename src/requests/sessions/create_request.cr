# Request Docs https://azutopia.gitbook.io/azu/endpoints/requests
module Authority::Sessions
  struct CreateRequest
    include Request

    getter username : String = ""
    getter password : String = ""
    getter remember : String = "false"
    getter forward_url : String = Base64.urlsafe_encode("/user-info")

    validate username, message: "Username must be present.", presence: true
    validate password, message: "Password must be present.", presence: true
    validate remember, message: "Remember must be present.", presence: false
    validate forward_url, message: "Forward_url must be present.", presence: false
  end
end
