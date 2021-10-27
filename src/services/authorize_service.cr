module Authority
  class AuthorizeService
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
  end
end
