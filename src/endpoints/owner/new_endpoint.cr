module Authority
  module Owner
    class NewEndpoint
      include Endpoint(NewOwnerRequest, NewOwnerResponse)

      get "/register"

      def call : NewOwnerResponse
        NewOwnerResponse.new new_owner_request
      end
    end
  end
end
