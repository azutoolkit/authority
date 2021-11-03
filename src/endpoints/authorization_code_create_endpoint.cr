# Endpoint Docs https://azutopia.gitbook.io/azu/endpoints
module Authority
  class AuthorizationCodeCreateEndpoint
    include Endpoint(AuthorizationCodeCreateRequest, EmptyResponse)
    post "/authorize"

    def call : EmptyResponse
      redirect to: authorization_code.forward_url
      EmptyResponse.new
    end

    private def authorization_code
      AuthorizationCodeService.new(authorization_code_create_request, user_id)
    end

    def user_id
      cookies["session_id"].value
    end
  end
end
