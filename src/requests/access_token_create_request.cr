# Request Docs https://azutopia.gitbook.io/azu/endpoints/requests
module Authority::AccessToken
  struct CreateRequest
    include Request

    getter grant_type : String
    getter code : String = ""
    getter redirect_uri : String = ""
    getter username : String = ""
    getter password : String = ""
    getter refresh_token : String = ""
    getter code_verifier : String = ""

    validate grant_type, message: "Param grant_type must be present.", presence: true

    validate username, presence: false
    validate password, presence: false
    validate code_verifier, presence: false
  end
end
