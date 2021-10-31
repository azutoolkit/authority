# Response Docs https://azutopia.gitbook.io/azu/endpoints/response
module Authority
  struct AccessTokenCreateResponse
    include Response

    def initialize(@response : Authly::AccessToken?)
    end

    def render
      @response.try &.to_json
    end
  end
end
