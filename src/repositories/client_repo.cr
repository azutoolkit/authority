module Authority
  module ClientRepo
    def self.get(other_id : String) : Client
      Client.find!(other_id)
    end

    def self.find_by!(other_client_id : String) : Client
      # Try cache first
      if client = ClientCacheService.get(other_client_id)
        return client
      end
      # Fall back to direct DB lookup if not in cache
      Client.find_by!(client_id: other_client_id)
    end

    def self.find_by(other_client_id : String) : Client?
      ClientCacheService.get(other_client_id)
    end

    def self.valid_redirect?(client_id : String, redirect_uri : String) : Bool
      Client.exists?(client_id: client_id, redirect_uri: redirect_uri)
    rescue e
      false
    end

    def self.authorized?(client_id : String, client_secret : String) : Bool
      Client.exists?(client_id: client_id, client_secret: client_secret)
    rescue e
      false
    end

    def self.create!(client : Clients::NewRequest)
      new_client = Client.new
      new_client.name = client.name
      new_client.client_id = UUID.random.to_s
      new_client.client_secret = Base64.urlsafe_encode(UUID.random.to_s, false)
      new_client.redirect_uri = client.redirect_uri
      new_client.description = client.description
      new_client.logo = client.logo
      new_client.scopes = "read,write"
      new_client.save!
      new_client
    end
  end
end
