# Endpoint for Token Introspection (RFC 7662)
module Authority::AccessToken
  class IntrospectEndpoint
    include Endpoint(IntrospectRequest, TokenInfoResponse)

    BASIC = "Basic"
    AUTH  = "Authorization"

    post "/oauth/introspect"

    def call : TokenInfoResponse
      header "Content-Type", "application/json;charset=UTF-8"
      header "Cache-Control", "no-store"
      header "Pragma", "no-cache"

      TokenIntrospectionService.call(header[AUTH], introspect_request)
    end

    private def credentials
      value = header[AUTH]
      client_id, client_secret = Base64.decode_string(value[BASIC.size + 1..-1]).split(":")
      {client_id, client_secret}
    end
  end
end
