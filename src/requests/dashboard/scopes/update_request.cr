# Admin Scopes Update Request
module Authority::Dashboard::Scopes
  struct UpdateRequest
    include Request

    getter id : String
    getter name : String = ""
    getter display_name : String = ""
    getter description : String = ""
    getter is_default : String = "false"
  end
end
