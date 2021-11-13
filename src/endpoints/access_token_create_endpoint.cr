# Endpoint Docs https://azutopia.gitbook.io/azu/endpoints
module Authority::AccessToken
  class CreateEndpoint
    include Endpoint(CreateRequest, JsonResponse)

    BASIC = "Basic"
    AUTH  = "Authorization"

    post "/token"

    def call : JsonResponse
      JsonResponse.new access_token.not_nil!
    end

    private def access_token : Authly::AccessToken
      AccessTokenService.access_token *credentials, create_request
    end

    private def credentials
      value = header[AUTH]
      client_id, client_secret = Base64.decode_string(value[BASIC.size + 1..-1]).split(":")
      {client_id, client_secret}
    end
  end
end
