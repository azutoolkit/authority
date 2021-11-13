module Authority::Clients
  class NewEndpoint
    include Endpoint(NewRequest, FormResponse)

    get "/clients/new"

    def call : FormResponse
      FormResponse.new new_request
    end
  end
end
