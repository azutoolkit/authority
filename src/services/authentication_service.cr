module Authority
  class AuthenticationService
    include SessionHelper

    def self.auth?(req)
      new(req).call
    end

    def initialize(@req : Sessions::CreateRequest)
    end

    def call
      return false unless Authly.owners.authorized?(@req.username, @req.password)
      owner = OwnerRepo.find!(@req.username)
      current_session.user_id = owner.id.to_s
      current_session.email = owner.email
      current_session.authenticated = true
    end
  end
end
