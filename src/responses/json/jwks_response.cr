# JSON Web Key Set Response (RFC 7517)
# Returns the public keys used to verify token signatures
module Authority
  struct JWKSResponse
    include Response

    def render
      {
        keys: JWKSService.jwks,
      }.to_json
    end
  end
end
