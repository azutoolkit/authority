# Admin Users Index Request
# Used for listing users with pagination and filters
module Authority::Dashboard::Users
  struct IndexRequest
    include Request

    getter page : Int32 = 1
    getter search : String = ""
    getter status : String = ""
    getter role : String = ""
  end
end
