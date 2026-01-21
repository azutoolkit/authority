# Response for Admin Users List page
module Authority::Dashboard::Users
  struct IndexResponse
    include Response
    include Templates::Renderable

    TEMPLATE = "admin/users/index.html"

    def initialize(
      @users : Array(User),
      @page : Int32 = 1,
      @per_page : Int32 = 20,
      @total_count : Int64 = 0,
      @search : String = "",
      @status : String = "",
      @role : String = "",
      @username : String = "",
      @errors : Array(String)? = nil
    )
    end

    def render
      view TEMPLATE, {
        users:       @users,
        page:        @page,
        per_page:    @per_page,
        total_count: @total_count,
        search:      @search,
        status:      @status,
        role:        @role,
        username:    @username,
        errors:      @errors,
      }
    end
  end
end
