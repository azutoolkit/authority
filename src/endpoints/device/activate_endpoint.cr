module Authority::Device
  class ShowVerifyEndpoint
    include SessionProvider
    include Endpoint(ActivateRequest, DeviceActivationForm | EmptyResponse)

    get "/activate"

    def call : DeviceActivationForm | EmptyResponse
      return signin unless user_logged_in?
      status 200

      header "Content-Type", "text/html; charset=UTF-8"
      header "Cache-Control", "no-store"
      header "Pragma", "no-cache"

      DeviceActivationForm.new activate_request
    end
  end
end
