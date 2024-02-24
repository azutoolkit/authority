module Authority
  class AuthenticateUser
    include SessionHelper

    def self.auth?(req)
      new(req).authorized?
    end

    def initialize(@req : Sessions::CreateRequest)
    end

    def authorized?
      return false unless Authly.owners.authorized?(@req.username, @req.password)
      owner = Authority.user_repo.find!(@req.username)
      current_user.user_id = owner.id.to_s
      current_user.email = owner.email
      current_user.authenticated = true
    end
  end
end
