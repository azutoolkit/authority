# Admin Client Update Request
# Used for updating an existing OAuth client
module Authority::Dashboard::Clients
  struct UpdateRequest
    include Request

    getter id : String = ""
    getter name : String = ""
    getter redirect_uri : String = ""
    getter description : String = ""
    getter logo : String = ""
    getter scopes : String = ""
    getter policy_url : String = ""
    getter tos_url : String = ""
    getter is_confidential : String = "true"
  end
end
