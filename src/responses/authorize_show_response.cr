# Response Docs https://azutopia.gitbook.io/azu/endpoints/response
module Authority
  struct AuthorizeShowResponse
    include Response
    include Templates::Renderable

    TEMPLATE = "authorize.html"

    def initialize(@authorize_show_request : AuthorizeShowRequest, @client : Client, @path : String)
    end

    def render
      render TEMPLATE, {
        code:                  @authorize_show_request.code.as(Authly::Response::Code).code,
        state:                 @authorize_show_request.state,
        scope:                 @authorize_show_request.scope,
        authorize_endpoint:    @path,
        code_challenge:        @authorize_show_request.code_challenge,
        code_challenge_method: @authorize_show_request.code_challenge_method,
        client:                {
          client_id:    @client.client_id,
          redirect_uri: @client.redirect_uri,
          name:         "Acme App",
          description:  "This example is a quick exercise to illustrate how the bottom navbar works.",
          scopes:       @client.scope,
        },
      }
    end
  end
end
