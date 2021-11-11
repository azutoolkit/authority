module Authority
  class AccessTokenService
    def self.access_token(client_id, client_secret, access_token_req)
      new(client_id, client_secret, access_token_req).access_token
    end

    def initialize(
      @client_id : String,
      @client_secret : String,
      @access_token_req : AccessToken::CreateRequest
    )
    end

    def access_token
      Authly.access_token(
        grant_type: @access_token_req.grant_type,
        client_id: @client_id,
        client_secret: @client_secret,
        username: @access_token_req.username,
        password: @access_token_req.password,
        redirect_uri: @access_token_req.redirect_uri,
        code: @access_token_req.code,
        verifier: @access_token_req.code_verifier,
        refresh_token: @access_token_req.refresh_token,
      )
    end
  end
end
