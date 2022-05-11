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
    validate logo, message: "Param logo must be a valid logo URL.", presence: true, match: /https?:\/\/[\S]+/
    validate redirect_uri, message: "Param redirect_uri must be valid redirect URL.", presence: true, match: /https?:\/\/[\S]+/
    # validate scopes, message: "Param scopes must be present.", presence: true
  end
end
