# Response for Admin Scopes List page
module Authority::Dashboard::Scopes
  struct IndexResponse
    include Response
    include Templates::Renderable

    TEMPLATE = "admin/scopes/index.html"

    def initialize(
      @scopes : Array(Scope),
      @page : Int32 = 1,
      @per_page : Int32 = 20,
      @username : String = "",
      @errors : Array(String)? = nil
    )
    end

    def render
      view TEMPLATE, {
        scopes:   @scopes,
        page:     @page,
        per_page: @per_page,
        username: @username,
        errors:   @errors,
      }
    end
  end
end
