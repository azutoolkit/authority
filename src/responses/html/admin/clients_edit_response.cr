# Response for Admin Client Edit page
module Authority::Dashboard::Clients
  struct EditResponse
    include Response
    include Templates::Renderable

    TEMPLATE = "admin/clients/edit.html"

    def initialize(
      @client : Client,
      @username : String = "",
      @errors : Array(String)? = nil
    )
    end

    def render
      view TEMPLATE, {
        client:   @client,
        username: @username,
        errors:   @errors,
      }
    end
  end
end
