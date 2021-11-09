module Authority
  struct NewOwnerResponse
    include Response
    include Templates::Renderable

    TEMPLATE = "new_owner.html"
    getter req : NewOwnerRequest, errors : Array(String)?

    def initialize(@req : NewOwnerRequest, @errors = nil)
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
