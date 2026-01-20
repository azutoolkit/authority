def create_client(client_id, client_secret, redirect_uri)
  id = UUID.random.to_s
  name = Faker::Company.name
  description = Faker::Lorem.paragraph(2)
  logo = Faker::Company.logo
  scopes = "read"
  now = Time.utc

  AuthorityDB.exec_query do |conn|
    conn.exec(
      "INSERT INTO oauth_clients (id, client_id, client_secret, redirect_uri, name, description, logo, scopes, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)",
      id, client_id, client_secret, redirect_uri, name, description, logo, scopes, now, now
    )
  end

  client = Authority::ClientEntity.new
  client.id = UUID.new(id)
  client.client_id = client_id
  client.client_secret = client_secret
  client.redirect_uri = redirect_uri
  client.name = name
  client.description = description
  client.logo = logo
  client.scopes = scopes
  client
end
