# Endpoint Docs https://azutopia.gitbook.io/azu/endpoints
module Authority::Authorize
  class CreateEndpoint
    include Endpoint(NewRequest, EmptyResponse)
    include SessionHelper

    post "/authorize"

    def call : EmptyResponse
      redirect to: authorization_code_url
      EmptyResponse.new
    end

    private def authorization_code_url
      AuthorizationCodeService.new(new_request,
        current_session.user_id).forward_url
    end
  end
end
