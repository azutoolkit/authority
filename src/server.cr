require "./authority"

Clear::Migration::Manager.instance.apply_all

# Start your server
# Add Handlers to your App Server
Authority.start Authority::HANDLERS
