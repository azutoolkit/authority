def create_client(client_id = UUID.random.to_s, client_secret = Faker::Internet.password(32, 32), redirect_uri = Faker::Internet.url("example.com"))
  Authority::ClientEntity.new({
    client_id:     client_id,
    client_secret: client_secret,
    redirect_uri:  redirect_uri,
    name:          Faker::Company.name,
    description:   Faker::Lorem.paragraph(2),
    logo:          Faker::Company.logo,
    scopes:        "read",
  }).save!
end
