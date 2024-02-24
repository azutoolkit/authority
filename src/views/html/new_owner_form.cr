module Authority::Owner
  struct NewOwnerForm
    include Response
    include Templates::Renderable

    getter req : Owner::NewRequest, errors : Array(String)?

    def initialize(@req : Owner::NewRequest, @errors = nil)
    end

    def render
      view data: {
        errors: errors,
        owner:  {
          first_name:       req.first_name,
          last_name:        req.last_name,
          email:            req.email,
          username:         req.username,
          password:         req.password,
          confirm_password: req.confirm_password,
        },
      }
    end
  end
end
