require "spec"
require "faker"
require "oauth2"
require "http/client"
require "./helpers/**"
require "./flows/**"
require "../src/authority"
require "digest"

CLIENT_ID      = Faker::Internet.user_name
CLIENT_SECCRET = Faker::Internet.password(32, 32)
REDIRECT_URI   = "http://www.example.com/callback"
OAUTH_CLIENT   = OAuth2::Client.new(
  "localhost", CLIENT_ID, CLIENT_SECCRET, port: 4000, scheme: "http",
  redirect_uri: REDIRECT_URI, authorize_uri: "/authorize", token_uri: "/token")

Spec.before_suite do
  Clear::SQL.truncate("clients", cascade: true)
  create_client(CLIENT_ID, CLIENT_SECCRET, REDIRECT_URI)
end

def clear_db
  Clear::SQL.truncate("authorization_codes", cascade: true)
  Clear::SQL.truncate("users", cascade: true)
end
