# Endpoint Docs https://azutopia.gitbook.io/azu/endpoints
module Authority::Authorize
  class NewEndpoint
    include SessionProvider
    include Endpoint(NewRequest, EmptyResponse | FormResponse)

    get "/authorize"

    def call : EmptyResponse | FormResponse
      return signin unless user_logged_in?

      header "Content-Type", "text/html; charset=UTF-8"
      header "Cache-Control", "no-store"
      header "Pragma", "no-cache"

      FormResponse.new(new_request, "/authorize")
    end
  end
end
