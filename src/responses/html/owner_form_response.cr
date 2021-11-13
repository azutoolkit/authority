module Authority::Owner
  struct FormResponse
    include Response
    include Templates::Renderable

    TEMPLATE = "new_owner_form.html"
    getter req : Owner::NewRequest, errors : Array(String)?

    def initialize(@req : Owner::NewRequest, @errors = nil)
    end

    def render
      render(TEMPLATE, {
        errors:     errors,
        first_name: req.first_name,
        last_name:  req.last_name,
        email:      req.email,
        username:   req.username,
        password:   req.password,
      })
    end
  end
end
