# Request Docs https://azutopia.gitbook.io/azu/endpoints/requests
module Authority
  struct TokenCreateRequest
    include Request

    getter grant_type : String
    getter redirect_uri : String = ""
    getter code : String = ""
    getter scope : String = "read"
    getter state : String = ""
    getter username : String = ""
    getter password : String = ""
    getter refresh_token : String = ""

    validate grant_type, message: "Param grant_type must be present.", presence: true
    validate scope, message: "Param scope must be present.", presence: false

    validate username, presence: false
    validate password, presence: false

    def grant(client_id, client_secret)
      Authly.authorize(
        grant_type,
        client_id,
        client_secret,
        redirect_uri,
        code,
        scope,
        state,
        username,
        password,
        refresh_token
      ).authorize!
    end
  end
end
