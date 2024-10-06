# Endpoint Docs https://azutopia.gitbook.io/azu/endpoints
module Authority::Authorize
  class NewEndpoint
    include SessionHelper
    include Endpoint(NewRequest, Response | FormResponse)

    get "/authorize"

    def call : Response | FormResponse
      return redirect_to_signin unless authenticated?

      header "Content-Type", "text/html; charset=UTF-8"
      header "Cache-Control", "no-store"
      header "Pragma", "no-cache"

      FormResponse.new(new_request, "/authorize")
    end
  end
end
