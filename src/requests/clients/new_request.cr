module Authority::Clients
  struct NewRequest
    include Request

    getter name : String = ""
    getter description : String = ""
    getter logo : String = ""
    getter redirect_uri : String = ""
    getter scopes : String = ""

    validate name, message: "Param name must be present.", presence: true
    validate description, message: "Param description must be present.", presence: true
    validate logo, message: "Param logo must be present.", presence: true
    validate redirect_uri, message: "Param redirect_uri must be present.", presence: true
    validate scopes, message: "Param scopes must be present.", presence: true
  end
end
