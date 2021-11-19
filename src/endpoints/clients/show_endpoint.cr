module Authority::Clients
  class ShowEndpoint
    include Endpoint(ShowRequest, ShowResponse)

    get "/clients/:id"

    def call : ShowResponse
      header "Content-Type", "text/html; charset=UTF-8"
      header "Cache-Control", "no-store"
      header "Pragma", "no-cache"
      ShowResponse.new client
    end

    def client
      ClientRepo.get(show_request.id)
    end
  end
end
