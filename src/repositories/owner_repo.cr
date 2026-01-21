module Authority
  module OwnerRepo
    def self.authenticate?(username : String, password : String)
      user = find!(username)
      return false unless user
      user.verify?(password)
    rescue
      false
    end

    def self.id_token(user_id : String) : Hash(String, Int64 | String)
      user = find_by_id(user_id)
      user.try(&.id_token) || {} of String => Int64 | String
    end

    def self.find!(username_or_email : String) : User
      user = find_by_username_or_email(username_or_email)
      raise "User not found" unless user
      user
    end

    def self.find_by_username_or_email(username_or_email : String) : User?
      # Try to find by username first
      user = User.find_by(username: username_or_email)
      return user if user

      # If not found by username, try by email
      User.find_by(email: username_or_email)
    end

    def self.find_by_id(user_id : String) : User?
      User.find_by(id: user_id)
    rescue
      nil
    end

    def self.create!(req : Owner::NewRequest)
      user = User.new
      user.id = UUID.random
      user.username = req.username
      user.email = req.email
      user.first_name = req.first_name
      user.last_name = req.last_name
      user.password = req.password
      user.scope = ""
      user.email_verified = false
      user.created_at = Time.utc
      user.updated_at = Time.utc
      user.save!
      user
    end
  end
end
