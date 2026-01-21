# Response for displaying client secret after creation
module Authority::Dashboard::Clients
  struct SecretResponse
    include Response
    include Templates::Renderable

    TEMPLATE = "admin/clients/secret.html"

    def initialize(
      @client : Client,
      @plain_secret : String,
      @username : String = ""
    )
    end

    def render
      view TEMPLATE, {
        client:       @client,
        plain_secret: @plain_secret,
        username:     @username,
      }
    end
  end
end
