# Pushed Authorization Requests (PAR) Service
# Implements RFC 9126 - OAuth 2.0 Pushed Authorization Requests.
# Allows clients to push authorization parameters before user redirect.
module Authority
  module PARService
    # PAR request expiration time in seconds
    PAR_EXPIRES_IN = 90

    # Request URI prefix per RFC 9126
    REQUEST_URI_PREFIX = "urn:ietf:params:oauth:request_uri:"

    # Create result type
    alias CreateResult = NamedTuple(
      success: Bool,
      request_uri: String?,
      expires_in: Int32?,
      error: String?,
      error_description: String?)

    # PAR request data type
    alias PARRequest = NamedTuple(
      redirect_uri: String,
      response_type: String,
      scope: String?,
      state: String?,
      code_challenge: String?,
      code_challenge_method: String?,
      nonce: String?)

    # Create a new PAR request.
    def self.create_request(
      client_id : String,
      redirect_uri : String,
      response_type : String,
      scope : String?,
      state : String?,
      code_challenge : String?,
      code_challenge_method : String?,
      nonce : String?,
    ) : CreateResult
      # Validate client exists
      unless client_exists?(client_id)
        return {
          success:           false,
          request_uri:       nil,
          expires_in:        nil,
          error:             "invalid_client",
          error_description: "Unknown client",
        }
      end

      # Generate unique request URI
      request_uri = "#{REQUEST_URI_PREFIX}#{Random::Secure.hex(32)}"
      expires_at = Time.utc + PAR_EXPIRES_IN.seconds

      # Store the request
      success = store_request(
        request_uri, client_id, redirect_uri, response_type,
        scope, state, code_challenge, code_challenge_method, nonce, expires_at
      )

      if success
        {
          success:           true,
          request_uri:       request_uri,
          expires_in:        PAR_EXPIRES_IN,
          error:             nil,
          error_description: nil,
        }
      else
        {
          success:           false,
          request_uri:       nil,
          expires_in:        nil,
          error:             "server_error",
          error_description: "Failed to store PAR request",
        }
      end
    end

    # Retrieve and consume a PAR request (single-use).
    def self.get_request(request_uri : String, client_id : String) : PARRequest?
      par = ParRequest.find_valid(request_uri, client_id)
      return nil unless par

      # Mark as used
      par.mark_used!

      {
        redirect_uri:          par.redirect_uri,
        response_type:         par.response_type,
        scope:                 par.scope,
        state:                 par.state,
        code_challenge:        par.code_challenge,
        code_challenge_method: par.code_challenge_method,
        nonce:                 par.nonce,
      }
    rescue
      nil
    end

    # Clean up expired PAR requests.
    def self.cleanup_expired(max_age : Time::Span = 5.minutes) : Int64
      ParRequest.cleanup_expired!
    rescue
      0_i64
    end

    private def self.client_exists?(client_id : String) : Bool
      Client.exists?(client_id: client_id)
    rescue
      false
    end

    private def self.store_request(
      request_uri : String,
      client_id : String,
      redirect_uri : String,
      response_type : String,
      scope : String?,
      state : String?,
      code_challenge : String?,
      code_challenge_method : String?,
      nonce : String?,
      expires_at : Time,
    ) : Bool
      par = ParRequest.new
      par.request_uri = request_uri
      par.client_id = client_id
      par.redirect_uri = redirect_uri
      par.response_type = response_type
      par.scope = scope
      par.state = state
      par.code_challenge = code_challenge
      par.code_challenge_method = code_challenge_method
      par.nonce = nonce
      par.expires_at = expires_at
      par.created_at = Time.utc
      par.save!
      true
    rescue
      false
    end

    private def self.mark_used(request_uri : String) : Bool
      par = ParRequest.find_by(request_uri: request_uri)
      return false unless par
      par.mark_used!
      true
    rescue
      false
    end
  end
end
