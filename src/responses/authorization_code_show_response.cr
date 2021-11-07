# Response Docs https://azutopia.gitbook.io/azu/endpoints/response
module Authority
  struct AuthorizationCodeShowResponse
    include Response
    include Templates::Renderable

    TEMPLATE = "authorize.html"

    getter authorize_show_request : AuthorizationCodeShowRequest
    getter client : Client
    getter path : String

    def initialize(@authorize_show_request : AuthorizationCodeShowRequest, @path : String)
      @client = @authorize_show_request.client
    end

    def render
      render TEMPLATE, {
        state:                 authorize_show_request.state,
        scope:                 authorize_show_request.scope,
        authorize_endpoint:    path,
        code_challenge:        authorize_show_request.code_challenge,
        code_challenge_method: authorize_show_request.code_challenge_method,
        response_type:         authorize_show_request.response_type,
        client:                {
          client_id:    client.client_id.to_s,
          redirect_uri: client.redirect_uri,
          name:         client.name,
          logo:         client.logo,
          description:  client.description,
          scopes:       client.scopes,
        },
      }
    end
  end
end
