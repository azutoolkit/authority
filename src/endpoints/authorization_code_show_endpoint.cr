# Endpoint Docs https://azutopia.gitbook.io/azu/endpoints
module Authority
  class AuthorizeShowEndpoint
    include Endpoint(AuthorizationCodeShowRequest, EmptyResponse | AuthorizationCodeShowResponse)

    get "/authorize"

    def call : EmptyResponse | AuthorizationCodeShowResponse
      return signin unless user_login?
      AuthorizationCodeShowResponse.new(authorization_code_show_request, "/authorize")
    end

    def signin
      redirect to: "/signin?forward_url=#{forward_url}", status: 302
      EmptyResponse.new
    end

    def forward_url
      Base64.urlsafe_encode(context.request.path + "?" + context.request.query.not_nil!)
    end

    def user_login?
      cookies["session_id"]?
    end
  end
end
