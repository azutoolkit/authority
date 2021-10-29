# Endpoint Docs https://azutopia.gitbook.io/azu/endpoints
module Authority
  class TokenCreateEndpoint
    include Endpoint(TokenCreateRequest, TokenCreateResponse)

    BASIC = "Basic"
    AUTH  = "Authorization"

    post "/token"

    def call : TokenCreateResponse
      access_token = TokenService.grant!(*credentials, token_create_request)
      TokenCreateResponse.new access_token
    end

    private def credentials
      value = header[AUTH]
      client_id, client_secret = Base64.decode_string(value[BASIC.size + 1..-1]).split(":")
      {client_id, client_secret}
    end
  end
end
