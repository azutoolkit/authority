module Authority::Owner
  struct FormResponse
    include Response
    include Templates::Renderable

    TEMPLATE = "auth/owner/new_owner_form.jinja"
    getter req : Owner::NewRequest, errors : Array(String)?

    def initialize(@req : Owner::NewRequest, @errors = nil)
    end

    def render
      view TEMPLATE, {
        errors:     errors,
        first_name: req.first_name,
        last_name:  req.last_name,
        email:      req.email,
        username:   req.username,
        password:   req.password,
      }
    end
  end
end
