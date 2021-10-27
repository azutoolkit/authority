# Endpoint Docs https://azutopia.gitbook.io/azu/endpoints
module Authority
  class AuthorizeShowEndpoint
    include Endpoint(AuthorizeShowRequest, EmptyResponse | AuthorizeShowResponse)

    get "/authorize"

    def call : EmptyResponse | AuthorizeShowResponse
      return signin unless user_login?
      authorize_response
    end

    def authorize_response
      client = authorize_show_request.client
      AuthorizeShowResponse.new(authorize_show_request, client, "/authorize")
    end

    def signin
      redirect to: "/signin?forward_url=#{location}", status: 302
      EmptyResponse.new
    end

    def location
      Base64.urlsafe_encode(context.request.path + "?" + context.request.query.not_nil!)
    end

    def user_login?
      cookies["session_id"]?
    end
  end
end
