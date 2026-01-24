# Response Docs https://azutopia.gitbook.io/azu/endpoints/response
module Authority::Device
  struct DeviceActivationConfirmation
    include Response
    include Templates::Renderable

    TEMPLATE = "auth/device/activation_confirmation.jinja"

    def render
      view TEMPLATE, {} of String => String
    end
  end
end
