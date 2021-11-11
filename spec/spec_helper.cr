require "spec"
require "faker"
require "oauth2"
require "http/client"
require "digest"

require "./helpers/**"
require "./flows/**"
require "../src/authority"

CLIENT_ID     = UUID.random.to_s
CLIENT_SECRET = Faker::Internet.password(32, 32)
REDIRECT_URI  = "http://www.example.com/callback"

OAUTH_CLIENT = OAuth2::Client.new(
  "localhost",
  CLIENT_ID,
  CLIENT_SECRET,
  port: 4000,
  scheme: "http",
  redirect_uri: REDIRECT_URI,
  authorize_uri: "/authorize",
  token_uri: "/token")

Clear::SQL.truncate("owners", cascade: true)
Clear::SQL.truncate("clients", cascade: true)
create_client(CLIENT_ID, CLIENT_SECRET, REDIRECT_URI)

Spec.before_each do
  Clear::SQL.truncate("owners", cascade: true)
end
