module Authority
  class ClientProvider
    include Authly::AuthorizableClient

    def valid_redirect?(client_id : String, redirect_uri : String) : Bool
      ClientRepo.valid_redirect?(client_id, redirect_uri)
    end

    def authorized?(client_id : String, client_secret : String) : Bool
      ClientRepo.authorized?(client_id, client_secret)
    end

    def allowed_scopes?(client_id : String, scopes : String) : Bool
      ScopeValidationService.validate(client_id, scopes).valid?
    end

    def allowed_grant_type?(client_id : String, grant_type : String) : Bool
      true # All grant types allowed by default since Client model doesn't track this
    end

    def any?(& : Authly::Client -> Bool) : Bool
      # Check if any client exists matching the block criteria
      # This is used by DeviceAuthorizationHandler to validate client_id
      clients = Client.query.all
      clients.each do |client|
        authly_client = Authly::Client.new(
          name: client.name,
          secret: client.client_secret,
          redirect_uri: client.redirect_uri,
          id: client.client_id,
          scopes: client.scopes
        )
        return true if yield authly_client
      end
      false
    end
  end
end
