require "azu"
Log.setup_from_env

module Authority
  include Azu

  SESSION_KEY     = ENV.fetch "SESSION_KEY", "session_id"
  BASE_URL        = ENV.fetch "BASE_URL", "http://localhost:4000"
  ACTIVATE_URL    = "#{BASE_URL}/activate"
  DEVICE_CODE_TTL = ENV.fetch("DEVICE_CODE_TTL", "300").to_i
  SESSION         = Session::CookieStore(UserSession).provider

  HANDLERS = [
    Azu::Handler::Rescuer.new,
    Azu::Handler::RequestID.new,
    Azu::Handler::Logger.new,
    Session::SessionHandler.new(Authority.session),
  ]

  def self.session
    SESSION
  end

  def self.current_session
    SESSION.current_session
  end

  configure do |c|
    c.templates.path = ENV["TEMPLATE_PATH"]
    c.router.get "/*", Handler::Static.new
  end
end
