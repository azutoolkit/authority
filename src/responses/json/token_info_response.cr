# Response Docs https://azutopia.gitbook.io/azu/endpoints/response
module Authority
  struct TokenInfoResponse
    include Response

    getter client_id : String

    def initialize(@client_id : String)
    end

    def render
      {
        active:    session.data.authenticated?,
        scope:     "",
        client_id: client_id,
        username:  session.data.email,
        exp:       session.timeout.from_now,
      }.to_json
    end

    def session
      Authority.session
    end

    def session_id
      session.session_id
    end
  end
end
