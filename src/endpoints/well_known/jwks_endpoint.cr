# JSON Web Key Set Endpoint (RFC 7517)
# GET /.well-known/jwks.json - Returns public keys for token verification
module Authority::WellKnown
  class JWKSEndpoint
    include Endpoint(Request, JWKSResponse)

    get "/.well-known/jwks.json"

    def call : JWKSResponse
      header "Content-Type", "application/json"
      header "Cache-Control", "public, max-age=3600"

      JWKSResponse.new
    end
  end
end
