module Authority::Clients
  class ShowEndpoint
    include Endpoint(ShowRequest, ShowResponse)

    get "/clients/:id"

    def call : ShowResponse
      ShowResponse.new client
    end

    def client
      ClientRepo.get(show_request.id)
    end
  end
end
