module Authority
  class RegisterNewClient
    def self.register(request)
      Authority.client_repo.create!(request)
    end
  end
end
