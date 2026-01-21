# Admin Scopes Create Request
module Authority::Dashboard::Scopes
  struct CreateRequest
    include Request

    getter name : String = ""
    getter display_name : String = ""
    getter description : String = ""
    getter is_default : String = "false"
  end
end
