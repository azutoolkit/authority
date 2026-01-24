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
      @total_count : Int64 = 0,
      @search : String = "",
      @confidentiality : String = "",
      @scope_filter : String = "",
      @sort_by : String = "created_at",
      @sort_dir : String = "DESC",
      @available_scopes : Array(String) = [] of String,
      @username : String = "",
      @errors : Array(String)? = nil
    )
    end

    def render
      view TEMPLATE, {
        clients:          @clients,
        page:             @page,
        per_page:         @per_page,
        total_count:      @total_count,
        total_pages:      (@total_count.to_f / @per_page).ceil.to_i,
        search:           @search,
        confidentiality:  @confidentiality,
        scope_filter:     @scope_filter,
        sort_by:          @sort_by,
        sort_dir:         @sort_dir,
        available_scopes: @available_scopes,
        username:         @username,
        errors:           @errors,
      }
    end
  end
end
