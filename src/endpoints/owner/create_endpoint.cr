module Authority
  module Owner
    class CreateEndpoint
      include Endpoint(NewOwnerRequest, NewOwnerResponse | EmptyResponse)

      post "/register"

      def call : NewOwnerResponse | EmptyResponse
        return owner_error unless new_owner_request.valid?
        OwnerService.register new_owner_request

        redirect to: "/signin"
        EmptyResponse.new
      end

      private def owner_error
        status 400
        NewOwnerResponse.new new_owner_request, owner_errors_html
      end

      private def owner_errors_html
        new_owner_request.errors.map do |error|
          "<b>#{error.field}:</b> #{error.message}"
        end
      end
    end
  end
end
