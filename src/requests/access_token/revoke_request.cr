# Token Revocation Request (RFC 7009)
module Authority
  struct RevokeRequest
    include Request

    getter token : String
    getter token_type_hint : String?

    validate token, message: "Token is required", presence: true
  end
end
