module Authority::Clients
  struct ShowResponse
    include Response
    include Templates::Renderable

    getter client : Client

    def initialize(@client : Client)
    end

    def render
      view data: {
        client_id:     client.client_id.to_s,
        client_secret: client.client_secret,
        name:          client.name,
        description:   client.description,
        logo:          client.logo,
        redirect_uri:  client.redirect_uri,
        scopes:        client.scopes,
      }
    end
  end
end
