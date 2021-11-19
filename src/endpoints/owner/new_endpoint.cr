module Authority::Owner
  class NewEndpoint
    include Endpoint(NewRequest, FormResponse)

    get "/register"

    def call : FormResponse
      header "Content-Type", "text/html; charset=UTF-8"
      header "Cache-Control", "no-store"
      header "Pragma", "no-cache"

      FormResponse.new new_request
    end
  end
end
