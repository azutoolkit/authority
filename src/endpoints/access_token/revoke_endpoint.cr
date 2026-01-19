# Endpoint for Token Revocation (RFC 7009)
module Authority::AccessToken
  class RevokeEndpoint
    include Endpoint(RevokeRequest, RevokeResponse)

    AUTH = "Authorization"

    post "/oauth/revoke"

    def call : RevokeResponse
      header "Content-Type", "application/json;charset=UTF-8"
      header "Cache-Control", "no-store"
      header "Pragma", "no-cache"

      TokenRevocationService.call(header[AUTH], revoke_request)
    end
  end
end
