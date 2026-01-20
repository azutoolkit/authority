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
      result = nil

      AuthorityDB.exec_query do |conn|
        conn.query_one?(
          "SELECT redirect_uri, response_type, scope, state, code_challenge, code_challenge_method, nonce " \
          "FROM oauth_par_requests " \
          "WHERE request_uri = $1 AND client_id = $2 AND used = FALSE AND expires_at > $3",
          request_uri, client_id, Time.utc
        ) do |row|
          result = {
            redirect_uri:          row.read(String),
            response_type:         row.read(String),
            scope:                 row.read(String?),
            state:                 row.read(String?),
            code_challenge:        row.read(String?),
            code_challenge_method: row.read(String?),
            nonce:                 row.read(String?),
          }
        end
      end

      # Mark as used if found
      if result
        mark_used(request_uri)
      end

      result
    rescue PQ::PQError
      nil
    end

    # Clean up expired PAR requests.
    def self.cleanup_expired(max_age : Time::Span = 5.minutes) : Int64
      cutoff = Time.utc - max_age
      rows_deleted = 0_i64

      AuthorityDB.exec_query do |conn|
        db_result = conn.exec(
          "DELETE FROM oauth_par_requests WHERE expires_at < $1 OR used = TRUE",
          cutoff
        )
        rows_deleted = db_result.rows_affected
      end

      rows_deleted
    rescue PQ::PQError
      0_i64
    end

    private def self.client_exists?(client_id : String) : Bool
      exists = false
      AuthorityDB.exec_query do |conn|
        conn.query_one?(
          "SELECT 1 FROM oauth_clients WHERE client_id = $1",
          client_id
        ) { |_| exists = true }
      end
      exists
    rescue PQ::PQError
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
      AuthorityDB.exec_query do |conn|
        conn.exec(
          "INSERT INTO oauth_par_requests " \
          "(request_uri, client_id, redirect_uri, response_type, scope, state, " \
          "code_challenge, code_challenge_method, nonce, expires_at) " \
          "VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)",
          request_uri, client_id, redirect_uri, response_type, scope, state,
          code_challenge, code_challenge_method, nonce, expires_at
        )
      end
      true
    rescue PQ::PQError
      false
    end

    private def self.mark_used(request_uri : String) : Bool
      AuthorityDB.exec_query do |conn|
        conn.exec(
          "UPDATE oauth_par_requests SET used = TRUE WHERE request_uri = $1",
          request_uri
        )
      end
      true
    rescue PQ::PQError
      false
    end
  end
end
