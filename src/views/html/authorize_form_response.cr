# Response Docs https://azutopia.gitbook.io/azu/endpoints/response
module Authority::Authorize
  struct FormResponse
    include Response
    include Templates::Renderable

    getter authorize_show_request : NewRequest
    getter client : Client

    # Scope descriptions for consent screen
    SCOPE_DESCRIPTIONS = {
      "read"    => "Read access to your data",
      "write"   => "Write access to your data",
      "profile" => "Access to your profile information",
      "email"   => "Access to your email address",
      "openid"  => "Verify your identity",
      "offline" => "Access your data while you're not logged in",
    }

    def initialize(@authorize_show_request : NewRequest)
      @client = @authorize_show_request.client
    end

    def initialize(@authorize_show_request : NewRequest, @action_path : String)
      @client = @authorize_show_request.client
    end

    def render
      view data: {
        state:                 authorize_show_request.state,
        scope:                 authorize_show_request.scope,
        scopes_with_descriptions: scopes_with_descriptions,
        authorize_endpoint:    NewEndpoint.path,
        code_challenge:        authorize_show_request.code_challenge,
        code_challenge_method: authorize_show_request.code_challenge_method,
        response_type:         authorize_show_request.response_type,
        nonce:                 authorize_show_request.nonce,
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

    private def scopes_with_descriptions
      authorize_show_request.scope.split(/[\s,]+/).map do |scope|
        {
          name:        scope,
          description: SCOPE_DESCRIPTIONS[scope]? || "Access to #{scope}",
        }
      end
    end
  end
end
