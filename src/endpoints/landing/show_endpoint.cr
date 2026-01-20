module Authority::Landing
  class ShowEndpoint
    include SecurityHeadersHelper
    include Endpoint(ShowRequest, PageResponse)

    get "/"

    def call : PageResponse
      set_security_headers!
      header "Content-Type", "text/html; charset=UTF-8"
      header "Cache-Control", "public, max-age=3600"

      PageResponse.new
    end
  end
end
