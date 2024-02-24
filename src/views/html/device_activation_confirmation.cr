# Response Docs https://azutopia.gitbook.io/azu/endpoints/response
module Authority::Device
  struct ActivationConfirmation
    include Response
    include Templates::Renderable

    def render
      view data: {} of String => String
    end
  end
end
