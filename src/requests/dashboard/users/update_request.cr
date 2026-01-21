# Admin Users Update Request
module Authority::Dashboard::Users
  struct UpdateRequest
    include Request

    getter id : String
    getter username : String = ""
    getter email : String = ""
    getter first_name : String = ""
    getter last_name : String = ""
    getter role : String = "user"
    getter scope : String = ""
    getter email_verified : String = "false"
  end
end
