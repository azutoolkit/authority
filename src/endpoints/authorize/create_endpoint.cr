# Endpoint Docs https://azutopia.gitbook.io/azu/endpoints
module Authority::Authorize
  class CreateEndpoint
    include Endpoint(NewRequest, Response)
    include SessionHelper

    post "/authorize"

    def call : Response
      redirect to: authorization_code_url
    end

    private def authorization_code_url
      AuthorizationCodeService.new(new_request,
        current_session.user_id).forward_url
    end
  end
end
