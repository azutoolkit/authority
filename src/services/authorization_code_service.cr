module Authority
  class AuthorizationCodeService
    getter auth_code_request : AuthorizeCreateRequest
    getter code : String

    def initialize(@auth_code_request : AuthorizeCreateRequest)
      @code = generate_code
    end

    def forward_url
      "#{auth_code_request.redirect_uri}?code=#{@code}&state=#{auth_code_request.state}"
    end

    private def generate_code
      Authly.code(auth_code_request.response_type,
        auth_code_request.client_id,
        auth_code_request.redirect_uri,
        auth_code_request.scope,
        auth_code_request.state,
        auth_code_request.code_challenge,
        auth_code_request.code_challenge_method).to_s
    end
  end
end
