require "./app"

Clear::Migration::Manager.instance.apply_all

# Start your server
# Add Handlers to your App Server
Authority.start [
  Azu::Handler::RequestID.new,
  Azu::Handler::Rescuer.new,
  Azu::Handler::Logger.new,
  Session::SessionHandler.new(Authority.session),
]
