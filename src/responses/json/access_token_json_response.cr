# Response Docs https://azutopia.gitbook.io/azu/endpoints/response
module Authority::AccessToken
  struct JsonResponse
    include Response

    def initialize(@access_token : Authly::AccessToken)
    end

    def render
      @access_token.to_json
    end
  end
end
