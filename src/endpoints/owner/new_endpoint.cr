module Authority::Owner
  class NewEndpoint
    include Endpoint(NewRequest, FormResponse)

    get "/register"

    def call : FormResponse
      FormResponse.new new_request
    end
  end
end
