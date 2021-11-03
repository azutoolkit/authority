# Request Docs https://azutopia.gitbook.io/azu/endpoints/requests
module Authority
  struct AccessTokenCreateRequest
    include Request

    getter grant_type : String
    getter redirect_uri : String = ""
    getter code : String = ""
    getter scope : String
    getter state : String = ""
    getter username : String = ""
    getter password : String = ""
    getter refresh_token : String = ""
    getter code_verifier : String = ""

    validate grant_type, message: "Param grant_type must be present.", presence: true
    validate scope, message: "Param scope must be present.", presence: false

    validate username, presence: false
    validate password, presence: false
    validate code_verifier, presence: false
  end
end
