module Authority::Device
  class ActivationEndpoint
    include Endpoint(ActivateRequest, DeviceActivationConfirmation)
    post "/activate"

    def call : DeviceActivationConfirmation
      status 200

      header "Content-Type", "text/html; charset=UTF-8"
      header "Cache-Control", "no-store"
      header "Pragma", "no-cache"

      activate!
      DeviceActivationConfirmation.new
    end

    private def activate!
      DeviceTokenService.activate! activate_request
    end
  end
end
