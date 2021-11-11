# Endpoint Docs https://azutopia.gitbook.io/azu/endpoints
module Authority::Session
  class NewEndpoint
    include Endpoint(CreateRequest, FormResponse)

    get "/signin"

    def call : FormResponse
      FormResponse.new create_request.forward_url
    end
  end
end
