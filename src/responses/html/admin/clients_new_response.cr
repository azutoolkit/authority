# Response for Admin Client New page (form display)
module Authority::Dashboard::Clients
  struct NewResponse
    include Response
    include Templates::Renderable

    TEMPLATE = "admin/clients/new.html"

    def initialize(
      @username : String = "",
      @errors : Array(String)? = nil,
      @name : String = "",
      @redirect_uri : String = "",
      @description : String = "",
      @logo : String = "",
      @scopes : String = "read",
      @policy_url : String = "",
      @tos_url : String = "",
      @is_confidential : Bool = true
    )
    end

    def render
      view TEMPLATE, {
        username:        @username,
        errors:          @errors,
        name:            @name,
        redirect_uri:    @redirect_uri,
        description:     @description,
        logo:            @logo,
        scopes:          @scopes,
        policy_url:      @policy_url,
        tos_url:         @tos_url,
        is_confidential: @is_confidential,
      }
    end
  end
end
