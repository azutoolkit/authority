require "spec"
require "faker"
require "oauth2"
require "http/client"
require "digest"
require "./helpers/**"
require "./flows/**"
require "../src/authority"

# Migrate DB
Clear::Migration::Manager.instance.apply_all

CLIENT_ID     = UUID.random.to_s
CLIENT_SECRET = Faker::Internet.password(32, 32)
REDIRECT_URI  = Faker::Internet.url("example.com")

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

# process = Process.new(
#   "./bin/authority",
#   env: ENV.to_h,
#   output: Process::Redirect::Inherit,
#   error: Process::Redirect::Inherit)
# # Wait for process to start
# sleep 1.seconds

Spec.after_suite do
  # process.not_nil!.signal Signal::KILL
end

Spec.before_each do
  Clear::SQL.truncate("owners", cascade: true)
end
