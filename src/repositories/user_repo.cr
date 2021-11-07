module Authority
  module UserRepo
    def self.authenticate?(username : String, password : String)
      find!(username).try &.verify?(password)
    rescue e
      false
    end

    def self.id_token(user_id : String)
      find!(user_id).try &.id_token
    end

    private def self.find!(username : String)
      User.query.find!({username: username})
    end
  end
end
