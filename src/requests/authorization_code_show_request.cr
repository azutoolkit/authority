# Request Docs https://azutopia.gitbook.io/azu/endpoints/requests
module Authority
  struct AuthorizationCodeShowRequest
    include Request

    getter response_type : String
    getter client_id : String
    getter redirect_uri : String
    getter scope : String
    getter state : String
    getter code_challenge : String = ""
    getter code_challenge_method : String = ""

    validate response_type, message: "Param response_type must be present.", presence: true
    validate client_id, message: "Param client_id must be present.", presence: true
    validate redirect_uri, message: "Param redirect_uri must be present.", presence: true
    validate scope, message: "Param scope must be present.", presence: true
    validate state, message: "Param state must be present.", presence: true

    validate code_challenge
    validate code_challenge_method

    def client
      Client.query.find!({
        client_id: client_id, redirect_uri: redirect_uri,
      })
    end
  end
end
