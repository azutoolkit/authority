module Authority
  class UserRepo
    include Authly::AuthorizableOwner

    def authorized?(username : String, password : String) : Bool
      find!(username).try &.verify?(password)
    rescue e
      false
    end

    def id_token(user_id : String) : Hash(String, Int64 | String)
      user = OwnerRepo.find_by_id(user_id)
      user.try(&.claims) || {} of String => Int64 | String
    end

    def find!(username : String)
      OwnerRepo.find!(username)
    end

    def create!(req : Owner::NewRequest)
      user = User.new
      user.first_name = req.first_name
      user.last_name = req.last_name
      user.email = req.email
      user.username = req.username
      user.scope = ""
      user.email_verified = false
      user.password = req.password
      user.save!
      user
    end
  end
end
