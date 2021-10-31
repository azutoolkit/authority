# Endpoint Docs https://azutopia.gitbook.io/azu/endpoints
module Authority
  class AuthorizeCreateEndpoint
    include Endpoint(AuthorizeCreateRequest, EmptyResponse)
    post "/authorize"

    def call : EmptyResponse
      redirect to: authorization_code.forward_url
      EmptyResponse.new
    end

    private def authorization_code
      AuthorizationCodeService.new(authorize_create_request)
    end
  end
end
