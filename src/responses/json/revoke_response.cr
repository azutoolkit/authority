# Token Revocation Response (RFC 7009)
# Per RFC 7009, the response is 200 OK regardless of whether the token was
# actually revoked (to prevent token scanning attacks)
module Authority
  struct RevokeResponse
    include Response

    def initialize(@success : Bool = true)
    end

    def render
      # RFC 7009 specifies empty response body on success
      ""
    end
  end
end
