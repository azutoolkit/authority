# Admin Users Create Request
module Authority::Dashboard::Users
  struct CreateRequest
    include Request

    getter username : String = ""
    getter email : String = ""
    getter password : String = ""
    getter first_name : String = ""
    getter last_name : String = ""
    getter role : String = "user"
    getter scope : String = ""
    getter email_verified : String = "false"
  end
end
