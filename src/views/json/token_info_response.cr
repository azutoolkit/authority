# Response Docs https://azutopia.gitbook.io/azu/endpoints/response
module Authority
  struct TokenInfoResponse
    include Response

    getter client_id : String

    def initialize(@client_id : String, @exp : String, @scope : String, @active : Bool = false)
    end

    def render
      {
        active:    @active,
        client_id: @client_id,
        scope:     @scope,
        exp:       @exp,
      }.to_json
    end
  end
end
