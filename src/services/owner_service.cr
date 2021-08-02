module Authority
  class OwnerService
    include Authly::AuthorizableOwner

    def authorized?(username : String, password : String)
      User.query.find({username: username, password: password})
    end
  end
end
