module Authority::Owner
  class TokenInfoEndpoint
    include Endpoint(TokenInfoRequest, TokenInfoResponse | Azu::Response::Error)

    BASIC = "Basic "
    AUTH  = "Authorization"

    post "/token_info"

    def call : TokenInfoResponse | Azu::Response::Error
      raise error("Invalid Authorization", 401, ["Unauthorized client"]) unless token_info_request.valid?
      header "Content-Type", "application/json; charset=UTF-8"
      header "Cache-Control", "no-store"
      header "Pragma", "no-cache"
      raise error("Invalid Authorization", 401, ["Unauthorized client"]) unless authorized?
      client_id, _ = credentials
      TokenInfoResponse.new client_id, token
    end

    private def authorized? : Bool
      Authly.clients.authorized?(*credentials)
    end

    private def credentials
      value = header[AUTH]
      puts value[BASIC.size + 1..-1]
      client_id, client_secret = Base64.decode_string(value[BASIC.size + 1..-1]).split(":")
      {client_id, client_secret}
    end
  end
end
