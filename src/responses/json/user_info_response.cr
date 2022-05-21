module Authority::Owner
  struct UserInfoResponse
    forward_missing_to @owner

    def initialize(@owner : OwnerEntity)
    end

    def render
      {
        "sub":                id,
        "name":               "#{first_name} #{last_name}",
        "given_name":         first_name,
        "family_name":        last_name,
        "preferred_username": username,
        "email":              email,
        "picture":            "http://example.com/#{username}/me.jpg",
      }.to_json
    end
  end
end
