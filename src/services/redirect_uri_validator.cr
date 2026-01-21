# Redirect URI Validator
# Validates OAuth redirect URIs against registered client URIs per RFC 6749.
# Prevents open redirect attacks by ensuring exact match with normalization.
module Authority
  module RedirectURIValidator
    # Validates that the redirect_uri matches the client's registered URI.
    #
    # @param client_id [String] The client ID to check against
    # @param redirect_uri [String] The redirect URI to validate
    # @return [Bool] True if the redirect_uri is valid for this client
    def self.valid?(client_id : String, redirect_uri : String) : Bool
      return false if redirect_uri.empty?

      # Reject URIs with fragments (per RFC 6749 section 3.1.2)
      return false if redirect_uri.includes?('#')

      registered_uri = find_client_redirect_uri(client_id)
      return false if registered_uri.nil?

      # Normalize and compare URIs
      compare_uris(registered_uri, redirect_uri)
    end

    # Find client's registered redirect_uri by client_id using Active Record
    private def self.find_client_redirect_uri(client_id : String) : String?
      Client.find_by(client_id: client_id).try(&.redirect_uri)
    rescue
      nil
    end

    # Compare two URIs with normalization.
    # Normalizes: scheme/host case, default ports, path traversal.
    # Public to allow use by RedirectURIService for multi-URI validation.
    def self.compare_uris(registered : String, provided : String) : Bool
      registered_normalized = normalize_uri(registered)
      provided_normalized = normalize_uri(provided)

      return false if registered_normalized.nil? || provided_normalized.nil?

      registered_normalized == provided_normalized
    end

    # Normalize a URI for comparison
    private def self.normalize_uri(uri_string : String) : String?
      uri = URI.parse(uri_string)
      scheme = uri.scheme
      host = uri.host
      return nil if scheme.nil? || host.nil?

      path = normalize_path(uri.path || "/")
      return nil if path.nil?

      build_normalized_uri(scheme.downcase, host.downcase, normalize_port(scheme, uri.port), path, uri.query)
    rescue
      nil
    end

    # Remove default ports (443 for https, 80 for http)
    private def self.normalize_port(scheme : String, port : Int32?) : Int32?
      return nil if port.nil?
      return nil if scheme.downcase == "https" && port == 443
      return nil if scheme.downcase == "http" && port == 80
      port
    end

    # Build the normalized URI string from components
    private def self.build_normalized_uri(scheme : String, host : String, port : Int32?, path : String, query : String?) : String
      result = "#{scheme}://#{host}"
      result += ":#{port}" if port
      result += path
      if q = query
        result += "?#{q}" unless q.empty?
      end
      result
    end

    # Normalize path by resolving . and .. components
    # Returns nil if path traversal attempts to go above root
    private def self.normalize_path(path : String) : String?
      return "/" if path.empty?

      segments = [] of String
      path.split('/').each do |segment|
        case segment
        when "", "."
          # Skip empty segments and current directory
        when ".."
          # Go up one directory
          if segments.empty?
            # Trying to go above root - this is suspicious
            return nil
          end
          segments.pop
        else
          segments << segment
        end
      end

      "/" + segments.join('/')
    end
  end
end
