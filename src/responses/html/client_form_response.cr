module Authority::Clients
  struct FormResponse
    include Response
    include Templates::Renderable

    TEMPLATE = "new_client_form.html"

    getter req : NewRequest, errors : Array(String)?

    def initialize(@req : NewRequest, @errors = nil)
    end

    def render
      view TEMPLATE, {
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
