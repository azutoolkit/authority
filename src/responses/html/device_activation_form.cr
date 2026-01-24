# Response Docs https://azutopia.gitbook.io/azu/endpoints/response
module Authority::Device
  struct DeviceActivationForm
    include Response
    include Templates::Renderable

    TEMPLATE = "auth/device/activation_form.jinja"

    getter activate_request : ActivateRequest

    def initialize(@activate_request : ActivateRequest)
    end

    def render
      view TEMPLATE, {
        target_device: activate_request.audience,
        user_code:     activate_request.user_code,
      }
    end
  end
end
