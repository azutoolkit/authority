module Authority::Owner
  class UserInfoEndpoint
    include Endpoint(UserInfoRequest, UserInfoResponse | Azu::Response::Error)

    get "/oauth2/userinfo"

    AUTH = "Authorization"

    def call : UserInfoResponse | Azu::Response::Error
      header "Content-Type", "application/json;"
      header "Cache-Control", "no-store"
      header "Pragma", "no-cache"

      res = GetUserInfo.claims(header[AUTH]?)
      res
    end
  end
end
