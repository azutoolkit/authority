module Authority::Owner
  struct UserInfoEndpoint
    include SessionHelper
    include Endpoint(UserInfoRequest, UserInfoResponse)
    private AUTHORIZATION = "Authorization"

    get "/user-info"
    post "/user-info"

    def call : UserInfoResponse
      UserInfoResponse.new owner
    end

    private def owner
      OwnerEntity.query.find!({id: user_id})
    end

    private def authorization
      header[AUTHORIZATION]
    end
  end
end
