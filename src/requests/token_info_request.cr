module Authority
  struct TokenInfoRequest
    include Request

    getter token : String
    validate token, message: "Token is required", presence: true
  end
end
