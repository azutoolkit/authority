# Endpoint Docs https://azutopia.gitbook.io/azu/endpoints
module Authority::Authorize
  class CreateEndpoint
    include Endpoint(NewRequest, EmptyResponse)
    post "/authorize"

    def call : EmptyResponse
      redirect to: authorization_code_url
      EmptyResponse.new
    end

    private def authorization_code_url
      AuthorizationCodeService.new(new_request, user_id).forward_url
    end

    def user_id
      Session.id(cookies).not_nil!.value.to_s
    end
  end
end
