module Authority
  class TokenService
    getter auth_code : AuthorizationCode?

    def self.grant!(client_id : String, client_secret : String, token_req : TokenCreateRequest)
      new(client_id, client_secret, token_req).grant!
    end

    def initialize(@client_id : String, @client_secret : String, @token_req : TokenCreateRequest)
    end

    def grant!
      return unless valid_code_challenge?
      Authly.authorize(
        @token_req.grant_type,
        @client_id,
        @client_secret,
        @token_req.redirect_uri,
        @token_req.code,
        @token_req.scope,
        @token_req.state,
        @token_req.username,
        @token_req.password,
        @token_req.refresh_token
      ).authorize!
    end

    private def valid_code_challenge?
      return true if @token_req.code_verifier.empty?

      code, method = code_challenge

      case method
      when "S256"  then code == @token_req.code_challenge
      when "plain" then code == @token_req.code_verifier
      end
    end

    private def code_challenge
      {auth_code.code_challenge, auth_code.code_challenge_method}
    end

    def auth_code
      @auth_code ||= AuthorizationCode.query.find!({
        client_id:          @client_id,
        authorization_code: @token_req.code,
        redirect_uri:       @token_req.redirect_uri,
      })
    end
  end
end
