# Response for Admin Audit Logs List page
module Authority::Dashboard::AuditLogs
  struct IndexResponse
    include Response
    include Templates::Renderable

    TEMPLATE = "admin/audit_logs/index.html"

    def initialize(
      @logs : Array(AuditLog),
      @page : Int32 = 1,
      @per_page : Int32 = 20,
      @total_count : Int64 = 0,
      @actors : Array(NamedTuple(id: String, email: String)) = [] of NamedTuple(id: String, email: String),
      @actions : Array(String) = [] of String,
      @filter_actor_id : String? = nil,
      @filter_action : String? = nil,
      @filter_resource_type : String? = nil,
      @filter_start_date : String? = nil,
      @filter_end_date : String? = nil,
      @username : String = "",
      @errors : Array(String)? = nil
    )
    end

    # Pre-calculate pagination display values
    private def display_from : Int64
      (@page - 1).to_i64 * @per_page + 1
    end

    private def display_to : Int64
      [@page.to_i64 * @per_page, @total_count].min
    end

    def render
      view TEMPLATE, {
        logs:                 @logs,
        page:                 @page,
        per_page:             @per_page,
        total_count:          @total_count,
        display_from:         display_from,
        display_to:           display_to,
        actors:               @actors,
        actions:              @actions,
        filter_actor_id:      @filter_actor_id,
        filter_action:        @filter_action,
        filter_resource_type: @filter_resource_type,
        filter_start_date:    @filter_start_date,
        filter_end_date:      @filter_end_date,
        username:             @username,
        errors:               @errors,
      }
    end
  end
end
