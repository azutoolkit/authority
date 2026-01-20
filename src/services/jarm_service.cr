# JARM Service (JWT Secured Authorization Response Mode)
# Implements the JARM specification for OAuth 2.0/OIDC.
# Creates signed JWT authorization responses per Financial-grade API requirements.
require "jwt"

module Authority
  module JARMService
    # Supported JARM response modes
    SUPPORTED_MODES = ["jwt", "query.jwt", "fragment.jwt", "form_post.jwt"]

    # JARM response expiration (short-lived)
    RESPONSE_TTL = 5.minutes

    # Result type for create_response
    alias CreateResult = NamedTuple(
      success: Bool,
      jwt: String?,
      error: String?,
      error_description: String?)

    # Create a signed JWT authorization response.
    #
    # @param client_id [String] The client ID (audience)
    # @param redirect_uri [String] The redirect URI
    # @param code [String?] The authorization code (for success)
    # @param state [String?] The state parameter
    # @param error [String?] Error code (for error responses)
    # @param error_description [String?] Error description
    # @return [CreateResult] Result with JWT or error
    def self.create_response(
      client_id : String,
      redirect_uri : String,
      code : String?,
      state : String?,
      error : String?,
      error_description : String?,
    ) : CreateResult
      # Build the JWT payload
      now = Time.utc
      payload = build_payload(
        client_id: client_id,
        code: code,
        state: state,
        error: error,
        error_description: error_description,
        issued_at: now,
        expires_at: now + RESPONSE_TTL
      )

      # Sign the JWT
      jwt = sign_jwt(payload)

      {
        success:           true,
        jwt:               jwt,
        error:             nil,
        error_description: nil,
      }
    rescue ex
      {
        success:           false,
        jwt:               nil,
        error:             "server_error",
        error_description: "Failed to create JARM response: #{ex.message}",
      }
    end

    # Build the redirect URL with the JWT response.
    #
    # @param redirect_uri [String] The base redirect URI
    # @param jwt [String] The signed JWT
    # @param response_mode [String] The response mode (jwt, query.jwt, fragment.jwt)
    # @return [String] The complete redirect URL
    def self.build_redirect_url(
      redirect_uri : String,
      jwt : String,
      response_mode : String,
    ) : String
      encoded_jwt = URI.encode_path_segment(jwt)

      case response_mode
      when "fragment.jwt"
        "#{redirect_uri}#response=#{encoded_jwt}"
      when "query.jwt", "jwt"
        separator = redirect_uri.includes?('?') ? '&' : '?'
        "#{redirect_uri}#{separator}response=#{encoded_jwt}"
      when "form_post.jwt"
        # Form post returns the JWT in the body, URL is just the redirect
        separator = redirect_uri.includes?('?') ? '&' : '?'
        "#{redirect_uri}#{separator}response=#{encoded_jwt}"
      else
        # Default to query.jwt
        separator = redirect_uri.includes?('?') ? '&' : '?'
        "#{redirect_uri}#{separator}response=#{encoded_jwt}"
      end
    end

    # Check if a response mode is a supported JARM mode.
    def self.supported_response_mode?(mode : String) : Bool
      SUPPORTED_MODES.includes?(mode)
    end

    # Decode and return the payload of a JWT (without verification).
    # Useful for debugging and testing.
    def self.decode_payload(jwt : String) : Hash(String, JSON::Any)?
      parts = jwt.split('.')
      return nil unless parts.size == 3

      payload_json = Base64.decode_string(parts[1])
      JSON.parse(payload_json).as_h
    rescue
      nil
    end

    # Build the JWT payload with required JARM claims.
    private def self.build_payload(
      client_id : String,
      code : String?,
      state : String?,
      error : String?,
      error_description : String?,
      issued_at : Time,
      expires_at : Time,
    ) : Hash(String, Int64 | String | Nil)
      payload = {} of String => Int64 | String | Nil

      # Required JARM claims
      payload["iss"] = issuer
      payload["aud"] = client_id
      payload["exp"] = expires_at.to_unix
      payload["iat"] = issued_at.to_unix

      # Authorization response parameters
      if code
        payload["code"] = code
      end

      if state
        payload["state"] = state
      end

      # Error response parameters
      if error
        payload["error"] = error
        payload["error_description"] = error_description if error_description
      end

      payload
    end

    # Sign the JWT using the configured algorithm and key.
    private def self.sign_jwt(payload : Hash(String, Int64 | String | Nil)) : String
      algorithm = Authly.config.algorithm
      secret_key = Authly.config.secret_key

      # Convert payload to the format JWT expects
      jwt_payload = {} of String => JSON::Any::Type
      payload.each do |key, value|
        case value
        when String
          jwt_payload[key] = value
        when Int64
          jwt_payload[key] = value
        when Nil
          # Skip nil values
        end
      end

      JWT.encode(jwt_payload, secret_key, algorithm)
    end

    # Get the issuer URL from configuration.
    private def self.issuer : String
      ENV.fetch("ISSUER") { "https://authority.example.com" }
    end
  end
end
