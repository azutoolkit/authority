# Response Docs https://azutopia.gitbook.io/azu/endpoints/response
module Authority::Device
  struct DeviceActivationConfirmation
    include Response
    include Templates::Renderable

    TEMPLATE = "device_activation_confirmation.html"

    def render
      view TEMPLATE, {} of String => String
    end
  end
end
