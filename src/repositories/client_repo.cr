module Authority
  module ClientRepo
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

    def self.create!(req : Clients::NewRequest)
    end
  end
end
