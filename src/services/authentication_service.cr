module Authority
  class AuthenticationService
    include SessionHelper

    def self.auth?(req)
      new(req).call
    end

    def initialize(@req : Sessions::CreateRequest)
    end

    def call
      if Authly.owners.authorized?(@req.username, @req.password)
        owner = OwnerRepo.find!(@req.username)
        current_session.data.user_id = owner.id.to_s
        current_session.data.email = owner.email
        current_session.data.authenticated = true
      else
        false
      end
    end
  end
end
