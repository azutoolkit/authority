require "authly"
# Configure
Authly.configure do |c|
  c.secret_key = ENV.fetch "SECRET_KEY"
  c.refresh_ttl = ENV.fetch("REFRESH_TTL").try &.to_i.minutes
  c.code_ttl = ENV.fetch("CODE_TTL").try &.to_i.minutes
  c.access_ttl = ENV.fetch("ACCESS_TOKEN_TTL").try &.to_i.minutes
  c.owners = Authority::OwnerProvider.new
  c.clients = Authority::ClientProvider.new
end
