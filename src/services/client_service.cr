module Authority
  class ClientService
    include Authly::AuthorizableClient

    def valid_redirect?(client_id : String, redirect_uri : String) : Bool
      Client.query.find!({client_id: client_id, redirect_uri: redirect_uri})
      true
    rescue e
      false
    end

    def authorized?(client_id : String, client_secret : String) : Bool
      Client.query.find!({client_id: client_id, client_secret: client_secret})
      true
    rescue e
      false
    end
  end
end
