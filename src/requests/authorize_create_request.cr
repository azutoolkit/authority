# Request Docs https://azutopia.gitbook.io/azu/endpoints/requests
module Authority
  struct AuthorizeCreateRequest
    include Request

    getter client_id : String
    getter redirect_uri : String
    getter scope : String = ""
    getter state : String
    getter code : String

    validate client_id, message: "Param client_id must be present.", presence: true
    validate redirect_uri, message: "Param redirect_uri must be present.", presence: true
    validate scope, message: "Param scope must be present.", presence: true
    validate state, message: "Param state must be present.", presence: true
    validate code, message: "Param code must be present.", presence: true
  end
end
