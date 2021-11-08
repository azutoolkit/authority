module Authority
  struct NewOwnerResponse
    include Response
    include Templates::Renderable

    TEMPLATE = "new_owner.html"

    def render
      render(TEMPLATE, {} of String => String)
    end
  end
end
