module Authority
  struct IntrospectRequest
    include Request

    getter token : String
    getter token_type_hint : String?

    validate token, message: "Token is required", presence: true
  end
end
