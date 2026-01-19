module Authority
  class TokenIntrospectionService
    @credentials : Tuple(String, String)

    def self.call(auth_header : String, introspect_request : IntrospectRequest)
      new(auth_header, introspect_request).call
    end

    def initialize(@auth_header : String, @introspect_request : IntrospectRequest)
      @credentials = credentials
    end

    def call : TokenInfoResponse
      exp, scope = parse_jwt_token
      TokenInfoResponse.new client_id, exp, scope, active?
    rescue ex
      TokenInfoResponse.new client_id, "", "", false
    end

    private def parse_jwt_token
      payload, _ = Authly.jwt_decode @introspect_request.token
      {payload["exp"].to_s, payload["scope"].to_s}
    end

    private def client_id
      credentials.first
    end

    private def active?
      @introspect_request.valid? && authorized? && !expired?
    end

    private def expired? : Bool
      payload, _ = Authly.jwt_decode @introspect_request.token
      exp = payload["exp"].as_i64
      Time.utc.to_unix > exp
    rescue
      true
    end

    private def authorized? : Bool
      Authly.clients.authorized?(*credentials)
    end

    private def credentials : Tuple(String, String)
      value = @auth_header
      creds = value.split(" ").last
      creds = Base64.decode_string(creds).split(":")
      client_id, client_secret = creds
      {client_id, client_secret}
    end
  end
end
