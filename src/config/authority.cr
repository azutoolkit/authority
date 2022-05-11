require "azu"

Log.setup_from_env

# Docs - https://azutopia.gitbook.io/azu/defining-your-app
module Authority
  # Defines Azu Framework
  include Azu

  SESSION_KEY     = ENV.fetch "SESSION_KEY", "session_id"
  BASE_URL        = ENV.fetch "BASE_URL", "http://localhost:4000"
  ACTIVATE_URL    = "#{BASE_URL}/activate"
  DEVICE_CODE_TTL = ENV.fetch("DEVICE_CODE_TTL", "300").to_i

  configure do |c|
    c.templates.path = "./public/templates"
    # Static Assets Handler
    c.router.get "/*", Handler::Static.new
  end
end
