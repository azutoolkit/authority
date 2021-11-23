module Authority::Clients
  class NewEndpoint
    include Endpoint(NewRequest, FormResponse)

    get "/clients/new"

    def call : FormResponse
      header "Content-Type", "text/html; charset=UTF-8"
      header "Cache-Control", "no-store"
      header "Pragma", "no-cache"
      FormResponse.new new_request
    end
  end
end
