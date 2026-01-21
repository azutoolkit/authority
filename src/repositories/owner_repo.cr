module Authority
  module OwnerRepo
    def self.authenticate?(username : String, password : String)
      find!(username).try &.verify?(password)
    rescue e
      false
    end

    def self.id_token(user_id : String)
      User.find!(user_id).try &.id_token
    end

    def self.find!(username_or_email : String)
      # Try finding by username first, then by email
      User.find_by(username: username_or_email) || User.find_by!(email: username_or_email)
    end

    def self.create!(req : Owner::NewRequest)
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
