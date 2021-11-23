module Authority
  module OwnerRepo
    def self.authenticate?(username : String, password : String)
      find!(username).try &.verify?(password)
    rescue e
      false
    end

    def self.id_token(user_id : String)
      find!(user_id).try &.id_token
    end

    private def self.find!(username : String)
      OwnerEntity.query.find!({username: username})
    end

    def self.create!(req : Owner::NewRequest)
      OwnerEntity.new({
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
