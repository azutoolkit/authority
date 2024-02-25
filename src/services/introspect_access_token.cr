module Authority
  class IntrospectAccessToken
    BASIC = "Basic"
    @credentials : Tuple(String, String)

    def self.info(auth_header : String, token_request : TokenInfoRequest)
      new(auth_header, token_request).call
    end

    def initialize(@auth_header : String, @token_request : TokenInfoRequest)
      @credentials = credentials
    end

    def call : TokenInfoResponse
      exp, scope = parse_jwt_token
      TokenInfoResponse.new client_id, exp, scope, active?
    rescue ex
      TokenInfoResponse.new client_id, "", "", false
    end

    private def parse_jwt_token
      payload, _ = Authly.jwt_decode @token_request.token
      {payload["exp"].to_s, payload["scope"].to_s}
    end

    private def client_id
      credentials.first
    end

    private def active?
      @token_request.valid? && authorized?
    end

    private def authorized? : Bool
      Authly.clients.authorized?(*credentials)
    end

    private def credentials : Tuple(String, String)
      client_id, client_secret = Base64.decode_string(@auth_header[BASIC.size + 1..-1]).split(":")
      {client_id, client_secret}
    end
  end
end
