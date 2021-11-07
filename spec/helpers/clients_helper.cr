def create_client(client_id, client_secret, redirect_uri)
  Authority::Client.new({
    client_id:     client_id,
    client_secret: client_secret,
    redirect_uri:  redirect_uri,
    name:          Faker::Company.name,
    description:   Faker::Lorem.paragraph(2),
    logo:          Faker::Company.logo,
    scopes:        "read",
  }).save!
end
