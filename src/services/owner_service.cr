module Authority
  class OwnerService
    include Authly::AuthorizableOwner

    def authorized?(username : String, password : String) : Bool
      User.query.find!({username: username, password: password})
      true
    rescue e
      false
    end

    def id_token(user_id : String) : Hash(String, String)
      owner = User.query.find!({username: user_id})

      {
        "user_id"    => owner.id.to_s,
        "first_name" => owner.first_name,
        "last_name"  => owner.last_name,
        "email"      => owner.email,
        "created_at" => owner.created_at.to_s,
        "updated_at" => owner.updated_at.to_s,
      }
    end
  end
end
