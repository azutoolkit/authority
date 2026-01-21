# Scope Validation Service
# Validates that requested OAuth scopes are within the client's allowed scopes.
module Authority
  class ScopeValidationService
    # Result struct returned by the validate method
    struct Result
      getter? valid : Bool
      getter scopes : String?
      getter error : String?
      getter error_description : String?

      def initialize(
        @valid : Bool,
        @scopes : String? = nil,
        @error : String? = nil,
        @error_description : String? = nil,
      )
      end
    end

    # Validates that the requested scopes are within the client's allowed scopes.
    #
    # @param client_id [String] The client ID to check scopes against
    # @param requested_scopes [String] Space or comma-separated list of requested scopes
    # @return [Result] Validation result with valid flag and error details
    def self.validate(client_id : String, requested_scopes : String) : Result
      # Query client scopes using direct SQL to handle UUID column type
      client_scopes = find_client_scopes(client_id)

      return Result.new(
        valid: false,
        error: "invalid_client",
        error_description: "Client not found"
      ) if client_scopes.nil?

      allowed = parse_scopes(client_scopes)
      requested = parse_scopes(requested_scopes)

      # Empty requested scopes is valid (will get default scopes)
      return Result.new(valid: true, scopes: requested_scopes) if requested.empty?

      invalid = requested - allowed

      if invalid.empty?
        Result.new(valid: true, scopes: requested_scopes)
      else
        Result.new(
          valid: false,
          error: "invalid_scope",
          error_description: "Client not authorized for scopes: #{invalid.join(", ")}"
        )
      end
    end

    # Find client scopes by client_id using Active Record
    private def self.find_client_scopes(client_id : String) : String?
      Client.find_by(client_id: client_id).try(&.scopes)
    rescue
      nil
    end

    # Parses a scope string into a Set of individual scopes.
    # Handles both space-separated and comma-separated scopes.
    private def self.parse_scopes(scopes : String) : Set(String)
      scopes.split(/[\s,]+/).reject(&.empty?).to_set
    end
  end
end
