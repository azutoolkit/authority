# Response Docs https://azutopia.gitbook.io/azu/endpoints/response
module Authority
  struct TokenCreateResponse
    include Response

    def initialize(@response : Authly::Response::AccessToken)
    end

    def render
      @response.to_json
    end
  end
end
