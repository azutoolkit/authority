# RFC 7591 Dynamic Client Registration Response
# https://datatracker.ietf.org/doc/html/rfc7591#section-3.2
module Authority
  struct ClientRegistrationResponse
    include Response
    include JSON::Serializable

    # Required: Unique client identifier
    getter client_id : String

    # Conditionally required: Client secret (not for public clients)
    @[JSON::Field(emit_null: false)]
    getter client_secret : String?

    # Optional: Time at which client_id was issued (Unix timestamp)
    getter client_id_issued_at : Int64

    # Optional: Time at which client_secret expires (0 = never)
    getter client_secret_expires_at : Int64

    # Echo back registered metadata
    getter client_name : String

    getter redirect_uris : Array(String)

    getter token_endpoint_auth_method : String

    getter grant_types : Array(String)

    getter response_types : Array(String)

    @[JSON::Field(emit_null: false)]
    getter scope : String?

    @[JSON::Field(emit_null: false)]
    getter logo_uri : String?

    @[JSON::Field(emit_null: false)]
    getter client_uri : String?

    @[JSON::Field(emit_null: false)]
    getter contacts : Array(String)?

    @[JSON::Field(emit_null: false)]
    getter tos_uri : String?

    @[JSON::Field(emit_null: false)]
    getter policy_uri : String?

    def initialize(
      @client_id : String,
      @client_secret : String?,
      @client_id_issued_at : Int64,
      @client_secret_expires_at : Int64,
      @client_name : String,
      @redirect_uris : Array(String),
      @token_endpoint_auth_method : String,
      @grant_types : Array(String),
      @response_types : Array(String),
      @scope : String? = nil,
      @logo_uri : String? = nil,
      @client_uri : String? = nil,
      @contacts : Array(String)? = nil,
      @tos_uri : String? = nil,
      @policy_uri : String? = nil
    )
    end

    def render
      self.to_json
    end
  end

  # RFC 7591 Error Response
  struct RegistrationErrorResponse
    include Response
    include JSON::Serializable

    getter error : String
    getter error_description : String

    def initialize(@error : String, @error_description : String)
    end

    def render
      self.to_json
    end
  end
end
