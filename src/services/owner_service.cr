module Authority
  class OwnerService
    def self.register(req : NewOwnerRequest)
      new(req).create!
    end

    def initialize(@req : NewOwnerRequest)
    end

    def create!
      User.new({
        first_name:     @req.first_name,
        last_name:      @req.last_name,
        email:          @req.email,
        username:       @req.username,
        password:       @req.password,
        email_verified: false,
        scope:          "",
      }).save!
    end
  end
end
