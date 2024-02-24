module Authority
  class CreateAccessToken
    include SessionHelper

    BASIC = "Basic"
    getter client_id : String, client_secret : String

    def self.access_token(authorization : String, access_token_req)
      new(authorization, access_token_req).call
    end

    def initialize(@authorization : String,
                   @access_token_req : AccessToken::CreateRequest)
      @client_id, @client_secret = credentials
    end

    def call
      token = access_token

      if id_token = token.id_token
        current_user.id_token = id_token
      end

      current_user.access_token = token.access_token

      access_token
    end

    private def credentials
      client_id, client_secret = Base64.decode_string(@authorization[BASIC.size + 1..-1]).split(":")
      {client_id, client_secret}
    end

    private def access_token
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
