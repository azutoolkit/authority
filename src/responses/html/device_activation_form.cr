# Response Docs https://azutopia.gitbook.io/azu/endpoints/response
module Authority::Device
  struct DeviceActivationForm
    include Response
    include Templates::Renderable

    TEMPLATE = "device_activation_form.html"

    getter activate_request : ActivateRequest

    def initialize(@activate_request : ActivateRequest)
    end

    def render
      render TEMPLATE, {
        target_device: activate_request.audience,
        user_code:     activate_request.user_code,
      }
    end
  end
end
