# Response Docs https://azutopia.gitbook.io/azu/endpoints/response
module Authority::Authorize
  struct FormResponse
    include Response
    include Templates::Renderable

    getter authorize_show_request : NewRequest
    getter client : Client

    def initialize(@authorize_show_request : NewRequest)
      @client = @authorize_show_request.client
    end

    def render
      view data: {
        state:                 authorize_show_request.state,
        scope:                 authorize_show_request.scope,
        authorize_endpoint:    NewEndpoint.path,
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
