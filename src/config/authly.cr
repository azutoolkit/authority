require "authly"
# Configure
Authly.configure do |config|
  config.secret_key = ENV.fetch "SECRET_KEY"
  config.refresh_ttl = ENV.fetch("REFRESH_TTL").try &.to_i.minutes
  config.code_ttl = ENV.fetch("CODE_TTL").try &.to_i.minutes
  config.access_ttl = ENV.fetch("ACCESS_TOKEN_TTL").try &.to_i.minutes
  config.owners = Authority::OwnerProvider.new
  config.clients = Authority::ClientProvider.new
end
