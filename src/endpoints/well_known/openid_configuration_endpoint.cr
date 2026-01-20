# OpenID Connect Discovery Endpoint (RFC 8414 / OpenID Connect Discovery 1.0)
# GET /.well-known/openid-configuration - Returns server metadata
module Authority::WellKnown
  class OpenIDConfigurationEndpoint
    include Endpoint(Request, OpenIDDiscoveryResponse)

    get "/.well-known/openid-configuration"

    def call : OpenIDDiscoveryResponse
      header "Content-Type", "application/json"
      header "Cache-Control", "public, max-age=3600"

      OpenIDDiscoveryResponse.new(Authority::BASE_URL)
    end
  end
end
