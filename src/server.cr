require "./authority"

# Run CQL migrations
AuthorityDB.migrator.up

# Initialize default settings if they don't exist
Authority::SettingsService.initialize_defaults

# Warm up caches in background (non-blocking)
Authority::ClientCacheService.warm_async

# Start your server
# Add Handlers to your App Server
Authority.start Authority::HANDLERS
