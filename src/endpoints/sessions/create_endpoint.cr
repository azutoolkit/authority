# Endpoint Docs https://azutopia.gitbook.io/azu/endpoints
module Authority::Sessions
  SIGNIN_PATH = "/signin"

  class CreateEndpoint
    include Endpoint(CreateRequest, FormResponse | Response)

    post SIGNIN_PATH

    def call : FormResponse | Response
      return request_error unless create_request.valid?

      if AuthenticationService.auth?(create_request)
        header "Content-Type", "application/json; charset=UTF-8"
        header "Cache-Control", "no-store"
        header "Pragma", "no-cache"

        redirect to: Base64.decode_string(create_request.forward_url), status: 302
      else
        unauthorized_error
      end
    end

    private def request_error(errors = client_errors)
      status 400
      FormResponse.new create_request.forward_url, errors
    end

    private def client_errors
      create_request.errors.map do |error|
        "<b>#{error.field}:</b> #{error.message}"
      end
    end

    private def unauthorized_error
      error "Invalid client", 400, ["Invalid credentials"]
    end
  end
end
