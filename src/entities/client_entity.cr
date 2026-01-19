# Entity alias for Client model
# This file provides backward compatibility
module Authority
  # ClientEntity is now defined in src/models/client.cr as Client
  # This file exists for backward compatibility with existing imports
  alias ClientEntity = Client
end
