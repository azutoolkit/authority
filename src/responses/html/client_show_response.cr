module Authority::Clients
  struct ShowResponse
    include Response
    include Templates::Renderable

    TEMPLATE = "auth/clients/show_client_page.jinja"

    getter client : ClientEntity, username : String

    def initialize(@client : ClientEntity, @username : String = "")
    end

    def render
      view TEMPLATE, {
        username:      username,
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
