module Authority::Clients
  class CreateEndpoint
    include Endpoint(NewRequest, FormResponse | EmptyResponse)

    post "/clients"

    def call : FormResponse | EmptyResponse
      return owner_error unless new_request.valid?
      ClientRepo.create! new_request

      redirect to: "/signin"
      EmptyResponse.new
    end

    private def owner_error
      status 400
      FormResponse.new new_request, owner_errors_html
    end

    private def owner_errors_html
      new_request.errors.map do |error|
        "<b>#{error.field}:</b> #{error.message}"
      end
    end
  end
end
