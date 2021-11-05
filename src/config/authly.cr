# Configure
Authly.configure do |c|
  c.secret_key = "ExampleSecretKey"
  c.refresh_ttl = 1.hour
  c.code_ttl = 1.hour
  c.access_ttl = 1.hour
  c.owners = Authority::OwnerProvider.new
  c.clients = Authority::ClientProvider.new
end
