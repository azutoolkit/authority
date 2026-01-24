# Pushed Authorization Request (PAR) Model
# Stores PAR requests for OAuth 2.0 Pushed Authorization Requests
module Authority
  class ParRequest
    include CQL::ActiveRecord::Model(String)
    db_context AuthorityDB, :oauth_par_requests

    property request_uri : String = ""
    property client_id : String = ""
    property redirect_uri : String = ""
    property response_type : String = ""
    property scope : String?
    property state : String?
    property code_challenge : String?
    property code_challenge_method : String?
    property nonce : String?
    property? used : Bool = false
    property expires_at : Time = Time.utc
    property created_at : Time?

    def initialize
    end

    def expired? : Bool
      Time.utc > expires_at
    end

    def valid_for_use? : Bool
      !used? && !expired?
    end

    def mark_used!
      @used = true
      update!
    end

    # Find a valid PAR request by URI and client
    def self.find_valid(request_uri : String, client_id : String) : ParRequest?
      par = find_by(request_uri: request_uri, client_id: client_id)
      return nil unless par
      return nil unless par.valid_for_use?
      par
    end

    # Cleanup expired and used requests, returns count of deleted rows
    def self.cleanup_expired! : Int64
      # Fetch and delete in memory to avoid complex DSL issues
      requests = ParRequest.query.all.select { |r| r.expired? || r.used? }
      count = requests.size.to_i64
      requests.each(&.delete!)
      count
    end
  end
end
