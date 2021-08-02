# Endpoint Docs https://azutopia.gitbook.io/azu/endpoints
module Authority
  class SessionShowEndpoint
    include Endpoint(SessionShowRequest, SessionShowResponse)

    get "/signin"

    def call : SessionShowResponse
      SessionShowResponse.new session_show_request.forward_url
    end
  end
end
