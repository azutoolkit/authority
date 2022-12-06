module Authority::Authorize
  class TokenInfoEndpoint
    include Endpoint(TokenInfoRequest, TokenInfoResponse)

    BASIC = "Basic "
    AUTH  = "Authorization"

    post "/token-info"

    def call : TokenInfoResponse
      header "Content-Type", "application/json; charset=UTF-8"
      header "Cache-Control", "no-store"
      header "Pragma", "no-cache"

      TokenInfoService.call(header[AUTH], token_info_request)
    end
  end
end
