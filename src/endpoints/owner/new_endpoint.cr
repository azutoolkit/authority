module Authority
  module Owner
    class NewEndpoint
      include Endpoint(NewOwnerRequest, NewOwnerResponse)

      get "/register"

      def call : NewOwnerResponse
        NewOwnerResponse.new
      end
    end
  end
end
