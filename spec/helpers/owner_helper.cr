def create_owner(username : String = Faker::Internet.email, password : String = Faker::Internet.password)
  user = Authority::User.new({
    username:       username,
    password:       password,
    first_name:     Faker::Name.first_name,
    last_name:      Faker::Name.last_name,
    email:          Faker::Internet.email,
    email_verified: true,
    scope:          "read",
  })

  user.save!
end
