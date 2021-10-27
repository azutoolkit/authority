# Endpoint Docs https://azutopia.gitbook.io/azu/endpoints
module Authority
  class AuthorizeCreateEndpoint
    include Endpoint(AuthorizeCreateRequest, EmptyResponse)
    post "/authorize"

    def call : EmptyResponse
      save_auth_code!
      redirect to: forward_url
      EmptyResponse.new
    end

    private def forward_url
      "#{approve_request.redirect_uri}?code=#{approve_request.code}&state=#{approve_request.state}"
    end

    private def save_auth_code!
      ClientService.save_auth_code authorize_create_request, user_id
    end

    private def user_id
      cookies["session_id"]?
    end

    private def approve_request
      authorize_create_request
    end
  end
end
