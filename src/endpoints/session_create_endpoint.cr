# Endpoint Docs https://azutopia.gitbook.io/azu/endpoints
module Authority
  class SessionCreateEndpoint
    include Endpoint(SessionCreateRequest, SessionShowResponse | EmptyResponse)

    post "/signin"

    def call : SessionShowResponse | EmptyResponse
      return session_error unless session_create_request.valid?
      return session_error(["Invalid credentials"]) unless authorized?
      create_session
      approve
    end

    private def session_error(errors = client_errors)
      status 400
      SessionShowResponse.new session_create_request.forward_url, errors
    end

    private def create_session
      cookies HTTP::Cookie.new(
        name: "session_id",
        value: session_create_request.username,
        expires: 1.minute.from_now,
        samesite: HTTP::Cookie::SameSite::Strict,
        secure: true
      )
    end

    private def approve
      redirect to: Base64.decode_string(session_create_request.forward_url), status: 302
      EmptyResponse.new
    end

    private def client_errors
      session_create_request.errors.map do |error|
        "<b>#{error.field}:</b> #{error.message}"
      end
    end

    private def authorized?
      OwnerService.new.authorized?(
        session_create_request.username,
        session_create_request.password
      )
    end
  end
end
