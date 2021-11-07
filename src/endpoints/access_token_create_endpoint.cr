# Endpoint Docs https://azutopia.gitbook.io/azu/endpoints
module Authority
  class AccessTokenCreateEndpoint
    include Endpoint(AccessTokenCreateRequest, AccessTokenCreateResponse)

    BASIC = "Basic"
    AUTH  = "Authorization"

    post "/token"

    def call : AccessTokenCreateResponse
      AccessTokenCreateResponse.new access_token
    end

    private def access_token : AccessToken
      AccessTokenService.access_token *credentials, access_token_create_request
    end

    private def credentials
      value = header[AUTH]
      client_id, client_secret = Base64.decode_string(value[BASIC.size + 1..-1]).split(":")
      {client_id, client_secret}
    end
  end
end
