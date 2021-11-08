module Authority
  struct NewOwnerRequest
    include Request

    getter username : String
    getter first_name : String
    getter last_name : String
    getter email : String
    getter password : String
    getter confirm_password : String
  end
end
