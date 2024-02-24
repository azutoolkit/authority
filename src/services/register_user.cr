module Authority
  class RegisterUser
    def self.register(request)
      Authority.user_repo.create! request
    end
  end
end
