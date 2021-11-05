module Authority
  class ClientService
    include Authly::AuthorizableClient

    def valid_redirect?(client_id : String, redirect_uri : String) : Bool
      ClientRepo.valid_redirect?(client_id, redirect_uri)
    end

    def authorized?(client_id : String, client_secret : String) : Bool
      ClientRepo.authorized?(client_id, client_secret)
    end
  end
end
