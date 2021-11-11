# Endpoint Docs https://azutopia.gitbook.io/azu/endpoints
module Authority::Session
  def self.id(cookies)
    cookies[SESSION_KEY]?
  end

  class CreateEndpoint
    include Endpoint(CreateRequest, FormResponse | EmptyResponse | Azu::Response::Error)

    post "/signin"

    def call : FormResponse | EmptyResponse | Azu::Response::Error
      return request_error unless create_request.valid?
      return unauthorized_error unless authorized?

      create_session
      redirect to: Base64.decode_string(create_request.forward_url), status: 302
      EmptyResponse.new
    end

    private def request_error(errors = client_errors)
      status 400
      FormResponse.new create_request.forward_url, errors
    end

    private def unauthorized_error
      status = HTTP::Status.new(400)
      Azu::Response::Error.new("Invalid client", status, ["Invalid credentials"])
    end

    private def create_session
      cookies HTTP::Cookie.new(
        name: SESSION_KEY,
        value: create_request.username,
        expires: 1.minute.from_now,
        samesite: HTTP::Cookie::SameSite::Strict,
        secure: true,
        http_only: true,
      )
    end

    private def client_errors
      create_request.errors.map do |error|
        "<b>#{error.field}:</b> #{error.message}"
      end
    end

    private def authorized?
      Authly.owners.authorized?(
        create_request.username,
        create_request.password
      )
    end
  end
end
