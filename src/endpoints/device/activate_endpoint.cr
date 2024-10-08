module Authority::Device
  class ShowVerifyEndpoint
    include SessionHelper
    include Endpoint(ActivateRequest, DeviceActivationForm | Response)

    get "/activate"

    def call : DeviceActivationForm | Response
      return redirect_to_signin unless authenticated?
      status 200

      header "Content-Type", "text/html; charset=UTF-8"
      header "Cache-Control", "no-store"
      header "Pragma", "no-cache"

      DeviceActivationForm.new activate_request
    end
  end
end
