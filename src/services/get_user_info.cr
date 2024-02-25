module Authority
  class GetUserInfo
    include SessionHelper

    BEARER = "Bearer"

    def self.claims(auth_header : String?)
      new(auth_header).call
    end

    def initialize(@auth_header : String?)
    end

    # Returns Claims if request token and session token match
    # Returns 401 unauthorized_error if the request token
    # and session token do not match.
    def call
      raise unauthorized_error unless token = valid_token?
      raise forbbidden_error unless valid_permissions?(token)
      UserInfoResponse.new user_claims
    end

    # Returns 401 Unauthorized error if request token is missing or invalid
    private def unauthorized_error(message = "Invalid or missing access token")
      Response::Error.new("401 Unauthorized", HTTP::Status::UNAUTHORIZED, [message])
    end

    # Returns 403 Forbidden error if request token does not match
    private def forbbidden_error(message = "Not enough permissions")
      Response::Error.new("403 Forbbidden", HTTP::Status::FORBIDDEN, [message])
    end

    # Returns user claims
    private def user_claims
      Authority.user_repo.id_token current_user.user_id
    end

    # Compares the existing access token with the session access token
    # Returns true if the access token matches the session access token
    # Returns false if the access token does not match the session access token
    # or throws an exception
    private def valid_token?
      token, _ = parse_bearer_token
      token
    rescue ex
      nil
    end

    private def valid_permissions?(payload)
      current_user.user_id == payload["sub"].as_s &&
        current_user.email == payload["email"].as_s
    rescue ex
      forbbidden_error "#{ex.message}"
    end

    # Parses token from Authorization header
    private def parse_bearer_token
      token = @auth_header.split(" ").last
      Authly.jwt_decode(token)
    end
  end
end
