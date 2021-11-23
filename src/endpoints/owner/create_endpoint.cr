module Authority::Owner
  class CreateEndpoint
    include Endpoint(NewRequest, FormResponse | EmptyResponse)

    post "/register"

    def call : FormResponse | EmptyResponse
      return owner_error_response unless new_request.valid?
      create_owner!

      header "Content-Type", "text/html; charset=UTF-8"
      header "Cache-Control", "no-store"
      header "Pragma", "no-cache"

      redirect to: "/signin"
      EmptyResponse.new
    end

    private def owner_error_response
      status 400
      FormResponse.new new_request, owner_errors_html
    end

    private def owner_errors_html
      new_request.errors.map do |error|
        "<b>#{error.field}:</b> #{error.message}"
      end
    end

    private def create_owner!
      OwnerRepo.create! new_request
    end
  end
end
