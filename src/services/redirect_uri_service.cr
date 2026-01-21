# Redirect URI Service
# Manages multiple redirect URIs per client as per RFC 7591.
# Provides validation and lookup for OAuth redirect URIs.
module Authority
  module RedirectURIService
    # Validates that the redirect_uri is registered for the client.
    # Checks against both primary redirect_uri and additional redirect_uris.
    #
    # @param client_id [String] The client ID to check against
    # @param redirect_uri [String] The redirect URI to validate
    # @return [Bool] True if the redirect_uri is registered for this client
    def self.valid?(client_id : String, redirect_uri : String) : Bool
      return false if redirect_uri.empty?
      return false if redirect_uri.includes?('#')

      uris = get_redirect_uris(client_id)
      return false if uris.nil?

      # Check if the URI matches any registered URI (with normalization)
      uris.any? { |registered| RedirectURIValidator.compare_uris(registered, redirect_uri) }
    end

    # Get all registered redirect URIs for a client.
    #
    # @param client_id [String] The client ID
    # @return [Array(String)?] Array of registered URIs, or nil if client not found
    def self.get_redirect_uris(client_id : String) : Array(String)?
      result = find_client_uris(client_id)
      return nil if result.nil?

      primary_uri, additional_uris = result

      uris = [] of String
      uris << primary_uri unless primary_uri.empty?

      if additional = additional_uris
        additional.split(',').each do |uri|
          trimmed = uri.strip
          uris << trimmed unless trimmed.empty? || uris.includes?(trimmed)
        end
      end

      uris.empty? ? nil : uris
    end

    # Find client's redirect URIs using Active Record
    private def self.find_client_uris(client_id : String) : Tuple(String, String?)?
      client = Client.find_by(client_id: client_id)
      return nil unless client
      {client.redirect_uri, client.redirect_uris}
    rescue
      nil
    end

    # Add a redirect URI to a client's list.
    #
    # @param client_id [String] The client ID
    # @param redirect_uri [String] The URI to add
    # @return [Bool] True if successfully added
    def self.add_uri(client_id : String, redirect_uri : String) : Bool
      current_uris = get_redirect_uris(client_id)
      return false if current_uris.nil?
      return true if current_uris.includes?(redirect_uri)

      new_uris = (current_uris + [redirect_uri]).join(',')
      update_redirect_uris(client_id, new_uris)
    end

    # Remove a redirect URI from a client's list.
    #
    # @param client_id [String] The client ID
    # @param redirect_uri [String] The URI to remove
    # @return [Bool] True if successfully removed
    def self.remove_uri(client_id : String, redirect_uri : String) : Bool
      current_uris = get_redirect_uris(client_id)
      return false if current_uris.nil?

      new_uris = current_uris.reject { |uri| uri == redirect_uri }
      return false if new_uris.empty? # Must have at least one URI

      update_redirect_uris(client_id, new_uris.join(','))
    end

    private def self.update_redirect_uris(client_id : String, uris : String) : Bool
      client = Client.find_by(client_id: client_id)
      return false unless client
      client.redirect_uris = uris
      client.update!
      true
    rescue
      false
    end
  end
end
