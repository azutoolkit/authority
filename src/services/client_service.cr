module Authority
  class ClientService
    include Authly::AuthorizableClient

    def self.save_auth_code(approve_request, user_id)
      AuthorizationCode.new({
        authorization_code: approve_request.code,
        client_id:          approve_request.client_id,
        user_id:            user_id,
        redirect_uri:       approve_request.redirect_uri,
        expires:            Authly.config.code_ttl.from_now,
        scope:              approve_request.scope,
        id_token:           "",
      }).save!
    end

    def valid_redirect?(id : String, redirect_uri : String)
      Client.query.find({client_id: id, redirect_uri: redirect_uri})
    end

    def authorized?(id : String, secret : String, redirect_uri : String, code : String)
      auth_code = AuthorizationCode.query.find!({
        client_id: id, authorization_code: code, redirect_uri: redirect_uri,
      })
      return false if auth_code.expired?
      true
    end

    def authorized?(id : String, secret : String)
      Client.query.find({client_id: id, client_secret: secret})
    end
  end
end
