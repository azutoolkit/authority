# Endpoint Docs https://azutopia.gitbook.io/azu/endpoints
module Authority
  class AuthorizeShowEndpoint
    include Endpoint(AuthorizeShowRequest, EmptyResponse | AuthorizeShowResponse)

    get "/oauth2/authorize"

    def call : EmptyResponse | AuthorizeShowResponse
      return signin unless user_login?

      auth_code = authorize_show_request.code.as(Authly::Response::Code)
      client = authorize_show_request.client
      scope = authorize_show_request.scope

      AuthorizeShowResponse.new auth_code.code, auth_code.state, scope, client
    end

    def signin
      location = context.request.path + "?" + context.request.query.not_nil!
      redirect to: "/signin?forward_url=#{Base64.urlsafe_encode(location)}", status: 302
      EmptyResponse.new
    end

    def user_login?
      cookies["session_id"]?
    end
  end
end
