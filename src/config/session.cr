require "session"

Session.configure do |config|
  config.timeout = 1.hour
  config.session_key = ENV.fetch "SESSION_KEY", "authority.sess"
  config.secret = ENV.fetch "SESSION_SECRET", "K,n:aT5CY4Trkg2JjS\e/?F[?e(Pj/n"
  config.on_started = ->(sid : String, data : Session::SessionData) { Authority.log.info { "Session started - SessionID: #{sid} - Databag: #{data}" } }
  config.on_deleted = ->(sid : String, data : Session::SessionData) { Authority.log.info { "Session Revoke - SessionID: #{sid} - Databag: #{data}" } }
  config.on_loaded = ->(sid : String, data : Session::SessionData) { Authority.log.info { "Session Loaded - SessionID: #{sid} - Databag: #{data}" } }
  config.on_client = ->(sid : String, data : Session::SessionData) { Authority.log.info { "Session Client - SessionID: #{sid} - Databag: #{data}" } }
end
