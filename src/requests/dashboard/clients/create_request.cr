# Admin Client Create Request
# Used for creating a new OAuth client
module Authority::Dashboard::Clients
  struct CreateRequest
    include Request

    getter name : String = ""
    getter redirect_uri : String = ""
    getter description : String = ""
    getter logo : String = ""
    getter scopes : String = "read"
    getter policy_url : String = ""
    getter tos_url : String = ""
    getter is_confidential : String = "true"
  end
end
