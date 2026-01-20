# Alias endpoint for /sessions/new (redirects to /signin)
module Authority::Sessions
  class SessionsNewEndpoint
    include SecurityHeadersHelper
    include Endpoint(CreateRequest, FormResponse)

    get "/sessions/new"

    def call : FormResponse
      set_security_headers!
      header "Content-Type", "text/html; charset=UTF-8"
      header "Cache-Control", "no-store"
      header "Pragma", "no-cache"

      FormResponse.new create_request.forward_url
    end
  end
end
