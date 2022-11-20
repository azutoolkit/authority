module Authority::Clients
  struct ShowResponse
    include Response
    include Templates::Renderable

    TEMPLATE = "show_client_page.html"

    getter client : ClientEntity

    def initialize(@client : ClientEntity)
    end

    def render
      view TEMPLATE, {
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
