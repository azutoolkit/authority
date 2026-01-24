# Response for Admin Settings page
module Authority::Dashboard::Settings
  struct IndexResponse
    include Response
    include Templates::Renderable

    TEMPLATE = "admin/settings/index.html"

    def initialize(
      @settings : Hash(String, Hash(String, String?)),
      @active_tab : String = "security",
      @username : String = "",
      @success : String? = nil,
      @errors : Array(String)? = nil
    )
    end

    def render
      view TEMPLATE, {
        settings:   @settings,
        active_tab: @active_tab,
        username:   @username,
        success:    @success,
        errors:     @errors,
      }
    end
  end
end
