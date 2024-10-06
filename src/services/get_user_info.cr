module Authority
  class GetUserInfo
    include SessionHelper

    BEARER                 = "Bearer"
    SUB                    = "sub"
    EMAIL                  = "email"
    INVALID_TOKEN          = "Invalid or missing access token"
    NOT_ENOUGH_PERMISSIONS = "Not enough permissions"

    def self.claims(auth_header : String?)
      new(auth_header).call
    end

    def initialize(@auth_header : String?)
    end

    # Returns user claims if the request token is valid
    # Returns 401 Unauthorized error if the request token is missing or invalid
    # Returns 403 Forbidden error if the request token does not match the session access token
    # or if the request token does not have enough permissions
    def call
      raise unauthorized_error unless token = valid_token?
      raise forbbidden_error unless valid_permissions?(token)
      user_claims
    end

    # Returns 401 Unauthorized error if request token is missing or invalid
    private def unauthorized_error(message = INVALID_TOKEN)
      Response::Error.new("401 Unauthorized", HTTP::Status::UNAUTHORIZED, [message])
    end

    # Returns 403 Forbidden error if request token does not match
    private def forbbidden_error(message = NOT_ENOUGH_PERMISSIONS)
      Response::Error.new("403 Forbbidden", HTTP::Status::FORBIDDEN, [message])
    end

    # Returns user claims
    private def user_claims
      Authority::UserRepo.new.id_token(user_id: current_session.user_id)
    end

    private def valid_token?
      if authorization = @auth_header
        _scheme, token = authorization.split(" ")
        jwt_token, _ = Authly.jwt_decode(token)
        jwt_token
      end
    rescue ex
      nil
    end

    private def valid_permissions?(payload : JSON::Any)
      current_session.user_id == payload[SUB].as_s &&
        current_session.email == payload[EMAIL].as_s
    end
  end
end
