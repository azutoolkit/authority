require "azu"
Log.setup_from_env

# Set template path before Azu configuration is accessed
# This ensures the Crinja loader gets the correct path at initialization
ENV["TEMPLATES_PATH"] ||= "#{Dir.current}/public/templates"

module Authority
  include Azu

  SESSION_KEY     = ENV.fetch "SESSION_KEY", "session_id"
  BASE_URL        = ENV.fetch "BASE_URL", "http://localhost:4000"
  ACTIVATE_URL    = "#{BASE_URL}/activate"
  DEVICE_CODE_TTL = ENV.fetch("DEVICE_CODE_TTL", "300").to_i
  SESSION         = Session::CookieStore(UserSession).provider

  HANDLERS = [
    Azu::Handler::Rescuer.new,
    Azu::Handler::RequestId.new,
    Azu::Handler::Logger.new,
    Session::SessionHandler.new(Authority.session),
    Azu::Handler::Static.new("public", fallthrough: true),
  ]

  def self.session
    SESSION
  end

  def self.current_session
    SESSION.current_session
  end

  # Static files are handled by Handler::Static in HANDLERS array
  # Do NOT add catch-all routes here - they intercept dynamic endpoints
end
