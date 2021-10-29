module Authority
  class AuthorizeService
    include Authly::Authorizable

    def self.save!(approve_request, user_id)
      AuthorizationCode.new({
        authorization_code:    approve_request.code,
        client_id:             approve_request.client_id,
        user_id:               user_id.not_nil!.value,
        redirect_uri:          approve_request.redirect_uri,
        expires:               Authly.config.code_ttl.from_now,
        scope:                 approve_request.scope,
        id_token:              "",
        code_challenge:        approve_request.code_challenge,
        code_challenge_method: approve_request.code_challenge_method,
      }).save!
    end

    def self.owner_authorized?(username : String, password : String)
      User.query.find!({username: username, password: password})
      true
    rescue e
      false
    end

    def self.client_authorized?(client_id : String, client_secret : String)
      Client.query.find!({client_id: client_id, client_secret: client_secret})
      true
    rescue e
      false
    end

    def self.authorize!(
      client_id : String,
      client_secret : String,
      token_req : TokenCreateRequest
    )
      new(client_id, client_secret, token_req).authorize!
    end

    getter auth_code : AuthorizationCode?
    getter code_verifier : String = ""

    def initialize(
      @client_id : String,
      @client_secret : String,
      @token_req : TokenCreateRequest
    )
    end

    def authorize!
      return unless valid_code_challenge?
      return unless auth_code.expired?

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
      return true if code_verifier.empty?
      code, method = auth_code.code_challenge, auth_code.code_challenge_method
      Authly::CodeChallengeBuilder.build(code, method).valid?(code_verifier)
    end

    def auth_code
      @auth_code ||= AuthorizationCode.query.find!({
        client_id:          @client_id,
        authorization_code: @code,
        redirect_uri:       @redirect_uri,
      }).expired?
    end
  end
end
