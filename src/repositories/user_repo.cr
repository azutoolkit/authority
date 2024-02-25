module Authority
  class UserRepo
    include Authly::AuthorizableOwner

    def authorized?(username : String, password : String) : Bool
      find!(username).try &.verify?(password)
    rescue e
      false
    end

    def id_token(user_id : String) : Hash(String, Int64 | String)
      User.query.find!({id: user_id}).try &.claims
    end

    def find!(username : String)
      User.query.find!({username: username})
    end

    def create!(req : Owner::NewRequest)
      User.new({
        first_name:     req.first_name,
        last_name:      req.last_name,
        email:          req.email,
        username:       req.username,
        password:       req.password,
        email_verified: false,
        scope:          "",
      }).save!
    end
  end
end
