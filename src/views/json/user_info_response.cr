module Authority
  struct UserInfoResponse
    include Response

    def initialize(@claims : Hash(String, String | Int64))
    end

    def render
      @claims.to_json
    end
  end
end
