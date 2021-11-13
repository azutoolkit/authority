module Authority
  module ClientRepo
    def self.get(other_id : String) : ClientEntity
      ClientEntity.query.find! { id == other_id }
    end

    def self.valid_redirect?(client_id : String, redirect_uri : String) : Bool
      ClientEntity.query.find!({client_id: client_id, redirect_uri: redirect_uri})
      true
    rescue e
      false
    end

    def self.authorized?(client_id : String, client_secret : String) : Bool
      ClientEntity.query.find!({client_id: client_id, client_secret: client_secret})
      true
    rescue e
      false
    end

    def self.create!(client : Clients::NewRequest)
      ClientEntity.new({
        client_id:     UUID.random,
        client_secret: Base64.urlsafe_encode(UUID.random.to_s, false),
        redirect_uri:  client.redirect_uri,
        name:          client.name,
        description:   client.description,
        logo:          client.logo,
        scopes:        "read,write",
      }).save!
    end
  end
end
