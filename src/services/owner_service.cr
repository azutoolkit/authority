module Authority
  class OwnerService
    include Authly::AuthorizableOwner

    def authorized?(username : String, password : String) : Bool
      user(username, password)
      true
    rescue e
      false
    end

    def id_token(username : String, password : String) : Hash(String, String)
      owner = user(username, password)

      {
        "first_name" => owner.first_name,
        "last_name"  => owner.last_name,
        "email"      => owner.email,
        "created_at" => owner.created_at.to_s,
        "updated_at" => owner.updated_at.to_s,
      }
    end

    private def user(username : String, password : String)
      User.query.find!({username: username, password: password})
    end
  end
end
