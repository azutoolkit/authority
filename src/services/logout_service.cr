# RP-Initiated Logout Service
# Implements OpenID Connect RP-Initiated Logout 1.0 specification.
# Handles logout request validation and redirect URL building.
module Authority
  module LogoutService
    # Validation result structure
    alias ValidationResult = NamedTuple(
      valid: Bool,
      error: String?,
      error_description: String?,
      client_id: String?)

    # Validate an RP-initiated logout request.
    #
    # @param id_token_hint [String?] The ID token previously issued to the client
    # @param post_logout_redirect_uri [String?] URI to redirect after logout
    # @param state [String?] Opaque value for maintaining state
    # @return [ValidationResult] Validation result with error details
    def self.validate_request(
      id_token_hint : String?,
      post_logout_redirect_uri : String?,
      state : String?,
    ) : ValidationResult
      # Without id_token_hint, we accept the request but can't validate redirect
      if id_token_hint.nil? || id_token_hint.empty?
        return {
          valid:             true,
          error:             nil,
          error_description: nil,
          client_id:         nil,
        }
      end

      # Validate the ID token hint
      client_id = extract_client_id_from_token(id_token_hint)
      if client_id.nil?
        return {
          valid:             false,
          error:             "invalid_request",
          error_description: "Invalid or expired id_token_hint",
          client_id:         nil,
        }
      end

      # If post_logout_redirect_uri is provided, validate it
      if uri = post_logout_redirect_uri
        unless valid_post_logout_redirect?(client_id, uri)
          return {
            valid:             false,
            error:             "invalid_request",
            error_description: "Invalid post_logout_redirect_uri",
            client_id:         client_id,
          }
        end
      end

      {
        valid:             true,
        error:             nil,
        error_description: nil,
        client_id:         client_id,
      }
    end

    # Build the post-logout redirect URL with optional state parameter.
    #
    # @param post_logout_redirect_uri [String?] The base redirect URI
    # @param state [String?] Optional state to append
    # @return [String?] The complete redirect URL, or nil
    def self.build_redirect_url(post_logout_redirect_uri : String?, state : String?) : String?
      return nil if post_logout_redirect_uri.nil? || post_logout_redirect_uri.empty?

      return post_logout_redirect_uri if state.nil? || state.empty?

      # Append state parameter
      separator = post_logout_redirect_uri.includes?('?') ? '&' : '?'
      "#{post_logout_redirect_uri}#{separator}state=#{state}"
    end

    # Extract client_id (audience) from an ID token.
    #
    # @param id_token [String?] The ID token JWT
    # @return [String?] The client_id, or nil if extraction fails
    def self.extract_client_id_from_token(id_token : String?) : String?
      return nil if id_token.nil? || id_token.empty?

      # Parse the JWT to extract claims (without full verification for logout)
      parts = id_token.split('.')
      return nil unless parts.size == 3

      # Decode the payload (middle part)
      payload_json = Base64.decode_string(parts[1])
      payload = JSON.parse(payload_json)

      # Extract 'aud' (audience) claim which is the client_id
      aud = payload["aud"]?
      return nil if aud.nil?

      # aud can be a string or array
      case aud
      when String
        aud.as_s
      when Array
        aud.as_a.first?.try(&.as_s)
      else
        nil
      end
    rescue
      nil
    end

    # Validate that post_logout_redirect_uri is allowed for the client.
    #
    # @param client_id [String?] The client ID
    # @param redirect_uri [String] The post-logout redirect URI
    # @return [Bool] True if the URI is valid
    def self.valid_post_logout_redirect?(client_id : String?, redirect_uri : String) : Bool
      # Without client_id, we can't validate - allow any
      return true if client_id.nil?

      # Basic URI validation
      return false if redirect_uri.empty?
      return false if redirect_uri.includes?('#')

      # Try to parse as URI
      begin
        uri = URI.parse(redirect_uri)
        return false if uri.scheme.nil? || uri.host.nil?
      rescue
        return false
      end

      # In a full implementation, we would check against registered
      # post_logout_redirect_uris for the client. For now, accept valid URIs.
      true
    end
  end
end
