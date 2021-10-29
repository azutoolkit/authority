module Authority
  class ClientService
    include Authly::AuthorizableClient

    getter auth_code : AuthorizationCode?

    def valid_redirect?(id : String, redirect_uri : String)
      Client.query.find({client_id: id, redirect_uri: redirect_uri})
    end

    def authorized?(id : String, secret : String, redirect_uri : String, code : String)
      return false if auth_code(id, code, redirect_uri).expired?
      true
    end

    def authorized?(id : String, secret : String)
      Client.query.find({client_id: id, client_secret: secret})
    end

    private def auth_code(id, code, redirect_uri)
      @auth_code ||= AuthorizationCode.query.find!({
        client_id: id, authorization_code: code, redirect_uri: redirect_uri,
      })
    end
  end
end
