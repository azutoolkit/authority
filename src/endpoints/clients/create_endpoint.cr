module Authority::Clients
  class CreateEndpoint
    include Endpoint(Clients::NewRequest, FormResponse | Response)

    post "/clients"

    def call : FormResponse | Response
      return owner_error unless new_request.valid?
      client = ClientRepo.create!(new_request).not_nil!
      redirect to: "/clients/#{client.id}"
    rescue e
      owner_error [e.message.to_s]
    end

    private def owner_error(errors : Array(String) = owner_errors_html)
      status 400
      FormResponse.new new_request, errors
    end

    private def owner_errors_html
      new_request.errors.map do |error|
        "<b>#{error.field}:</b> #{error.message}"
      end
    end
  end
end
