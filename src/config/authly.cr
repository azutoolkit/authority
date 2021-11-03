# Configure
Authly.configure do |c|
  # Secret Key for JWT Tokens
  c.secret_key = "ExampleSecretKey"

  # Refresh Token Time To Live
  c.refresh_ttl = 1.hour

  # Authorization Code Time To Live
  c.code_ttl = 1.hour

  # Access Token Time To Live
  c.access_ttl = 1.hour

  # Using your own classes
  c.owners = Authority::OwnerService.new
  c.clients = Authority::ClientService.new
end
