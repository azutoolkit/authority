def create_client(client_id, client_secret, redirect_uri)
  now = Time.utc

  client = Authority::Client.new
  client.id = UUID.random
  client.client_id = client_id
  client.client_secret = client_secret
  client.redirect_uri = redirect_uri
  client.name = Faker::Company.name
  client.description = Faker::Lorem.paragraph(2)
  client.logo = Faker::Company.logo
  client.scopes = "read"
  client.created_at = now
  client.updated_at = now
  client.save!

  client
end
