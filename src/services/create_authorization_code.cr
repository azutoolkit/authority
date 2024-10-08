module Authority
  class CreateAuthorizationCode
    getter auth_code_request : Authorize::NewRequest
    getter code : String
    getter user_id : String

    def self.url(request, user_id)
      new(request, user_id).forward_url
    end

    def initialize(@auth_code_request : Authorize::NewRequest, @user_id : String)
      @code = generate_code
    end

    def forward_url
      "#{auth_code_request.redirect_uri}?code=#{@code}&state=#{auth_code_request.state}"
    end

    private def generate_code
      Authly.code(
        auth_code_request.response_type,
        auth_code_request.client_id,
        auth_code_request.redirect_uri,
        auth_code_request.scope,
        auth_code_request.code_challenge,
        auth_code_request.code_challenge_method,
        user_id).to_s
    end
  end
end
