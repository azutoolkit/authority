require "session"

Session.configure do |c|
  c.timeout = 1.hour
  c.session_key = ENV.fetch "SESSION_KEY", "authority.sess"
  c.secret = ENV.fetch "SESSION_SECRET", "K,n:aT5CY4Trkg2JjS\e/?F[?e(Pj/n"
  c.on_started = ->(sid : String, data : Session::Databag) { Authority.log.info { "Session started - SessionID: #{sid} - Databag: #{data}" } }
  c.on_deleted = ->(sid : String, data : Session::Databag) { Authority.log.info { "Session Revoke - SessionID: #{sid} - Databag: #{data}" } }
  c.on_loaded = ->(sid : String, data : Session::Databag) { Authority.log.info { "Session Loaded - SessionID: #{sid} - Databag: #{data}" } }
  c.on_client = ->(sid : String, data : Session::Databag) { Authority.log.info { "Session Client - SessionID: #{sid} - Databag: #{data}" } }
end
