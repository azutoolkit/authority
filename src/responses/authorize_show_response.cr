# Response Docs https://azutopia.gitbook.io/azu/endpoints/response
module Authority
  struct AuthorizeShowResponse
    include Response
    include Templates::Renderable

    TEMPLATE = "authorize.html"

    def initialize(@code : String, @state : String, @scope : String, @client : Client)
    end

    def render
      render TEMPLATE, {
        code:   @code,
        state:  @state,
        scope:  @scope,
        client: {
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
