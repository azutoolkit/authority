module Authority::Device
  class TokenEndpoint
    include Endpoint(TokenRequest, AccessTokenResponse)
    post "/device/token"

    def call : AccessTokenResponse
      status 201

      header "Content-Type", "application/json;charset=UTF-8"
      header "Cache-Control", "no-store"
      header "Pragma", "no-cache"

      AccessTokenResponse.new access_token
    end

    def access_token
      DeviceTokenService.token token_request
    end
  end
end
