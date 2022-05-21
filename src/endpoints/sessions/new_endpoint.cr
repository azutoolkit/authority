# Endpoint Docs https://azutopia.gitbook.io/azu/endpoints
module Authority::Sessions
  class NewEndpoint
    include Endpoint(CreateRequest, FormResponse)

    get SIGNIN_PATH

    def call : FormResponse
      header "Content-Type", "text/html; charset=UTF-8"
      header "Cache-Control", "no-store"
      header "Pragma", "no-cache"

      FormResponse.new create_request.forward_url
    end
  end
end
