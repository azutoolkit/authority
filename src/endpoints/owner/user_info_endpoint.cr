module Authority::Owner
  alias UserInfoRes = UserInfoResponse | Azu::Response::Error

  class UserInfoEndpoint
    include Endpoint(UserInfoRequest, UserInfoRes)

    get "/oauth2/userinfo"

    AUTH = "Authorization"

    def call : UserInfoRes
      header "Content-Type", "application/json;"
      header "Cache-Control", "no-store"
      header "Pragma", "no-cache"

      user_claims = GetUserInfo.claims(auth_header)

      UserInfoResponse.new user_claims
    end

    private def auth_header : String?
      header[AUTH]?
    end
  end
end
