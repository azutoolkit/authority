module Authority
  struct UserInfoRequest
    include Request

    getter id_token : String = ""
    validate id_token, message: "An id token is required", presence: true
  end
end
