require "spec"
require "faker"
require "oauth2"
require "http/client"
require "./helpers/**"
require "./flows/**"
require "../src/authority"
require "digest"

Spec.before_suite do
  clear_db
  Clear::SQL.truncate("clients", cascade: true)
  create_client(CLIENT_ID, CLIENT_SECCRET, REDIRECT_URI)
end

def clear_db
  Clear::SQL.truncate("authorization_codes", cascade: true)
  Clear::SQL.truncate("users", cascade: true)
end
