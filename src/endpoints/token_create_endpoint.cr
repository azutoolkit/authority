# Endpoint Docs https://azutopia.gitbook.io/azu/endpoints
module Authority
  class TokenCreateEndpoint
    include EndpointHelpers
    include Endpoint(TokenCreateRequest, TokenCreateResponse)

    post "/oauth2/token"

    def call : TokenCreateResponse
      access_token = token_create_request.grant(*credentials)
      # Todo: Store token info? - What kind of persistence it needs?
      TokenCreateResponse.new access_token
    end
  end
end
