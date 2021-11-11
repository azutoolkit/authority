module Authority
  class OwnerProvider
    include Authly::AuthorizableOwner

    def authorized?(username : String, password : String) : Bool
      OwnerRepo.authenticate? username, password
    end

    def id_token(owner_id : String) : Hash(String, Int64 | String)
      OwnerRepo.id_token owner_id
    end
  end
end
