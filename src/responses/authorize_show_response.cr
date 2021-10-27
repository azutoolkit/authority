# Response Docs https://azutopia.gitbook.io/azu/endpoints/response
module Authority
  struct AuthorizeShowResponse
    include Response
    include Templates::Renderable

    TEMPLATE = "authorize.html"

    def initialize(@auth : Authly::Response::Code, @scope : String, @client : Client, @path : String)
    end

    def render
      render TEMPLATE, {
        code:               @auth.code,
        state:              @auth.state,
        scope:              @scope,
        authorize_endpoint: @path,
        client:             {
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
