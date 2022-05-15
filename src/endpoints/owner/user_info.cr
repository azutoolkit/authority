module Authority::Owner
  struct UserInfoEndpoint
    include Endpoint(UserInfoRequest, UserInfoResponse)
    private AUTHORIZATION = "Authorization"

    get "/user-info"
    post "/user-info"

    def call : UserInfoResponse
      UserInfoResponse.new owner
    end

    private def owner
      Session.get authorization
    end

    private def authorization
      header[AUTHORIZATION]
    end
  end
end
