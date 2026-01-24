# RFC 7591 Dynamic Client Registration Request
# https://datatracker.ietf.org/doc/html/rfc7591#section-2
module Authority::Register
  struct CreateRequest
    include Request
    include JSON::Serializable

    # Required: Array of redirect URIs
    @[JSON::Field(key: "redirect_uris")]
    getter redirect_uris : Array(String) = [] of String

    # Optional: Human-readable client name
    @[JSON::Field(key: "client_name")]
    getter client_name : String = ""

    # Optional: Authentication method for token endpoint
    @[JSON::Field(key: "token_endpoint_auth_method")]
    getter token_endpoint_auth_method : String = "client_secret_basic"

    # Optional: Grant types the client will use
    @[JSON::Field(key: "grant_types")]
    getter grant_types : Array(String) = ["authorization_code"]

    # Optional: Response types the client will use
    @[JSON::Field(key: "response_types")]
    getter response_types : Array(String) = ["code"]

    # Optional: URL of client homepage
    @[JSON::Field(key: "client_uri")]
    getter client_uri : String = ""

    # Optional: URL of client logo
    @[JSON::Field(key: "logo_uri")]
    getter logo_uri : String = ""

    # Optional: Space-separated list of scopes
    getter scope : String = ""

    # Optional: Contact emails
    getter contacts : Array(String) = [] of String

    # Optional: Terms of service URL
    @[JSON::Field(key: "tos_uri")]
    getter tos_uri : String = ""

    # Optional: Privacy policy URL
    @[JSON::Field(key: "policy_uri")]
    getter policy_uri : String = ""

    # Supported grant types
    SUPPORTED_GRANT_TYPES = [
      "authorization_code",
      "client_credentials",
      "password",
      "refresh_token",
      "urn:ietf:params:oauth:grant-type:device_code",
    ]

    # Supported response types
    SUPPORTED_RESPONSE_TYPES = ["code", "token"]

    # Supported authentication methods
    SUPPORTED_AUTH_METHODS = ["client_secret_basic", "client_secret_post", "none"]

    def valid? : Bool
      errors.empty? && validate_metadata
    end

    def errors : Array(NamedTuple(field: String, message: String))
      errs = [] of NamedTuple(field: String, message: String)

      if redirect_uris.empty?
        errs << {field: "redirect_uris", message: "redirect_uris is required"}
      end

      errs
    end

    def validate_metadata : Bool
      validate_redirect_uris &&
        validate_grant_types &&
        validate_response_types &&
        validate_auth_method
    end

    def validate_redirect_uris : Bool
      return false if redirect_uris.empty?

      redirect_uris.all? do |uri|
        parsed = URI.parse(uri)
        # Must be https or http (for localhost dev)
        valid_scheme = parsed.scheme.in?(["https", "http"])
        # Must not contain fragment
        no_fragment = parsed.fragment.nil? || parsed.fragment.try(&.empty?)
        valid_scheme && no_fragment
      end
    end

    def validate_grant_types : Bool
      grant_types.all? { |grant_type| SUPPORTED_GRANT_TYPES.includes?(grant_type) }
    end

    def validate_response_types : Bool
      response_types.all? { |response_type| SUPPORTED_RESPONSE_TYPES.includes?(response_type) }
    end

    def validate_auth_method : Bool
      SUPPORTED_AUTH_METHODS.includes?(token_endpoint_auth_method)
    end

    def redirect_uri_error? : Bool
      return true if redirect_uris.empty?
      !validate_redirect_uris
    end

    def grant_type_error? : Bool
      !validate_grant_types
    end

    def response_type_error? : Bool
      !validate_response_types
    end

    def auth_method_error? : Bool
      !validate_auth_method
    end

    def public_client? : Bool
      token_endpoint_auth_method == "none"
    end
  end
end
