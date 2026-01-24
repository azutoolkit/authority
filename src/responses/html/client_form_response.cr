module Authority::Clients
  struct FormResponse
    include Response
    include Templates::Renderable

    TEMPLATE = "auth/clients/new_client_form.jinja"

    getter req : NewRequest, errors : Array(String)?, username : String

    def initialize(@req : NewRequest, @errors = nil, @username : String = "")
    end

    def render
      view TEMPLATE, {
        username:     username,
        errors:       errors,
        name:         req.name,
        description:  req.description,
        logo:         req.logo,
        redirect_uri: req.redirect_uri,
        scopes:       req.scopes,
      }
    end
  end
end
