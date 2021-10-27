def create_client(client_id, client_secret, redirect_uri)
  client = Authority::Client.new({
    client_id:     client_id,
    client_secret: client_secret,
    redirect_uri:  redirect_uri,
    grant_types:   "cleint_credentials",
    scope:         "read",
  })

  client.save!
end
