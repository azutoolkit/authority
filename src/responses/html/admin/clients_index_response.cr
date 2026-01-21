# Response for Admin Clients List page
module Authority::Dashboard::Clients
  struct IndexResponse
    include Response
    include Templates::Renderable

    TEMPLATE = "admin/clients/index.html"

    def initialize(
      @clients : Array(Client),
      @page : Int32 = 1,
      @per_page : Int32 = 20,
      @username : String = "",
      @errors : Array(String)? = nil
    )
    end

    def render
      view TEMPLATE, {
        clients:  @clients,
        page:     @page,
        per_page: @per_page,
        username: @username,
        errors:   @errors,
      }
    end
  end
end
