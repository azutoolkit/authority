require "./spec_helper"

describe Authority do
  describe "OpenID Connect Discovery" do
    client = HTTP::Client.new("localhost", 4000)

    describe "GET /.well-known/openid-configuration" do
      it "returns server metadata" do
        response = client.get("/.well-known/openid-configuration")
        response.status_code.should eq 200

        metadata = JSON.parse(response.body)

        # Required fields
        metadata["issuer"].should eq Authority::BASE_URL
        metadata["authorization_endpoint"].should eq "#{Authority::BASE_URL}/authorize"
        metadata["token_endpoint"].should eq "#{Authority::BASE_URL}/token"
        metadata["userinfo_endpoint"].should eq "#{Authority::BASE_URL}/oauth2/userinfo"
        metadata["jwks_uri"].should eq "#{Authority::BASE_URL}/.well-known/jwks.json"
      end

      it "returns supported grant types" do
        response = client.get("/.well-known/openid-configuration")
        metadata = JSON.parse(response.body)

        grant_types = metadata["grant_types_supported"].as_a.map(&.as_s)
        grant_types.should contain "authorization_code"
        grant_types.should contain "client_credentials"
        grant_types.should contain "password"
        grant_types.should contain "refresh_token"
        grant_types.should contain "urn:ietf:params:oauth:grant-type:device_code"
      end

      it "returns supported scopes" do
        response = client.get("/.well-known/openid-configuration")
        metadata = JSON.parse(response.body)

        scopes = metadata["scopes_supported"].as_a.map(&.as_s)
        scopes.should contain "openid"
        scopes.should contain "profile"
        scopes.should contain "email"
      end

      it "returns PKCE code challenge methods" do
        response = client.get("/.well-known/openid-configuration")
        metadata = JSON.parse(response.body)

        methods = metadata["code_challenge_methods_supported"].as_a.map(&.as_s)
        methods.should contain "S256"
        methods.should contain "plain"
      end

      it "returns token introspection endpoint" do
        response = client.get("/.well-known/openid-configuration")
        metadata = JSON.parse(response.body)

        metadata["introspection_endpoint"].should eq "#{Authority::BASE_URL}/oauth/introspect"
      end

      it "returns token revocation endpoint" do
        response = client.get("/.well-known/openid-configuration")
        metadata = JSON.parse(response.body)

        metadata["revocation_endpoint"].should eq "#{Authority::BASE_URL}/oauth/revoke"
      end

      it "returns device authorization endpoint" do
        response = client.get("/.well-known/openid-configuration")
        metadata = JSON.parse(response.body)

        metadata["device_authorization_endpoint"].should eq "#{Authority::BASE_URL}/device/code"
      end

      it "returns supported response types" do
        response = client.get("/.well-known/openid-configuration")
        metadata = JSON.parse(response.body)

        response_types = metadata["response_types_supported"].as_a.map(&.as_s)
        response_types.should contain "code"
        response_types.should contain "token"
      end

      it "returns supported claims" do
        response = client.get("/.well-known/openid-configuration")
        metadata = JSON.parse(response.body)

        claims = metadata["claims_supported"].as_a.map(&.as_s)
        claims.should contain "sub"
        claims.should contain "iss"
        claims.should contain "email"
        claims.should contain "email_verified"
      end

      it "returns signing algorithm" do
        response = client.get("/.well-known/openid-configuration")
        metadata = JSON.parse(response.body)

        algs = metadata["id_token_signing_alg_values_supported"].as_a.map(&.as_s)
        algs.should contain "HS256"
      end

      it "sets proper cache headers" do
        response = client.get("/.well-known/openid-configuration")

        response.headers["Content-Type"].should eq "application/json"
        response.headers["Cache-Control"].should eq "public, max-age=3600"
      end
    end

    describe "GET /.well-known/jwks.json" do
      it "returns JSON Web Key Set" do
        response = client.get("/.well-known/jwks.json")
        response.status_code.should eq 200

        jwks = JSON.parse(response.body)
        jwks["keys"].should be_a JSON::Any
      end

      it "returns empty keys for symmetric algorithm" do
        # HS256 uses symmetric keys which are not published
        response = client.get("/.well-known/jwks.json")
        jwks = JSON.parse(response.body)

        jwks["keys"].as_a.should be_empty
      end

      it "sets proper cache headers" do
        response = client.get("/.well-known/jwks.json")

        response.headers["Content-Type"].should eq "application/json"
        response.headers["Cache-Control"].should eq "public, max-age=3600"
      end
    end
  end
end
