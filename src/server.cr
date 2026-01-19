require "./authority"

# Run CQL migrations
AuthorityDB.migrator.up

# Start your server
# Add Handlers to your App Server
Authority.start Authority::HANDLERS
