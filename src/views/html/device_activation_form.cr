# Response Docs https://azutopia.gitbook.io/azu/endpoints/response
module Authority::Device
  struct ActivationForm
    include Response
    include Templates::Renderable

    getter activate_request : ActivateRequest

    def initialize(@activate_request : ActivateRequest)
    end

    def render
      view data: {
        target_device: activate_request.audience,
        user_code:     activate_request.user_code,
      }
    end
  end
end
