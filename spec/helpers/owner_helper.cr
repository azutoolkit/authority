def create_owner(username : String = Faker::Internet.email, password : String = Faker::Internet.password)
  user = Authority::OwnerEntity.new
  user.username = username
  user.password = password
  user.first_name = Faker::Name.first_name
  user.last_name = Faker::Name.last_name
  user.email = Faker::Internet.email
  user.email_verified = true
  user.scope = "read"
  user.save!
  user
end
