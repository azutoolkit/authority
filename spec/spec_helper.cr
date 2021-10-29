require "spec"
require "faker"
require "oauth2"
require "http/client"
require "digest"

require "./helpers/**"
require "./flows/**"
require "../src/authority"

CLIENT_ID     = Faker::Internet.user_name
CLIENT_SECRET = Faker::Internet.password(32, 32)
REDIRECT_URI  = "http://www.example.com/callback"

OAUTH_CLIENT = OAuth2::Client.new(
  "localhost", CLIENT_ID, CLIENT_SECRET, port: 4000, scheme: "http",
  redirect_uri: REDIRECT_URI, authorize_uri: "/authorize", token_uri: "/token")

Spec.before_each do
  Clear::SQL.truncate("authorization_codes", cascade: true)
  Clear::SQL.truncate("users", cascade: true)
  Clear::SQL.truncate("clients", cascade: true)

  create_client(CLIENT_ID, CLIENT_SECRET, REDIRECT_URI)
end

def prepare_code_challenge_url(username, password)
  state = Random::Secure.hex
  code_verifier = Faker::Internet.password(43, 128)

  code_challenge_method = "S256"
  code_challenge = Digest::SHA256.base64digest(code_verifier)

  auth_url = OAUTH_CLIENT.get_authorize_uri(scope: "read", state: state) do |param|
    param.add "code_challenge", code_challenge
    param.add "code_challenge_method", code_challenge_method
  end

  code, expected_state = AuthorizationCodeFlux.flow(auth_url, username, password)

  {code, code_verifier, expected_state}
end
