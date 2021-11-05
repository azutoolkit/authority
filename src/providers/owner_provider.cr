module Authority
  class OwnerProvider
    include Authly::AuthorizableOwner

    def authorized?(username : String, password : String) : Bool
      UserRepo.authenticate? username, password
    end

    def id_token(user_id : String) : Hash(String, Int64 | String)
      UserRepo.id_token user_id
    end
  end
end
