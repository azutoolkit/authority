require "./spec_helper"

# RFC 7591 - OAuth 2.0 Dynamic Client Registration Protocol
describe "Dynamic Client Registration (RFC 7591)" do
  describe "POST /register" do
    it "registers a new client with required metadata" do
      response = register_client({
        "client_name"   => "Test Application",
        "redirect_uris" => ["https://example.com/callback"],
      })

      response.status_code.should eq 201

      body = JSON.parse(response.body)
      body["client_id"].as_s.should_not be_empty
      body["client_secret"].as_s.should_not be_empty
      body["client_name"].as_s.should eq "Test Application"
      body["redirect_uris"].as_a.first.as_s.should eq "https://example.com/callback"
    end

    it "registers a client with all optional metadata" do
      response = register_client({
        "client_name"              => "Full Metadata App",
        "redirect_uris"            => ["https://example.com/callback", "https://example.com/callback2"],
        "token_endpoint_auth_method" => "client_secret_basic",
        "grant_types"              => ["authorization_code", "refresh_token"],
        "response_types"           => ["code"],
        "client_uri"               => "https://example.com",
        "logo_uri"                 => "https://example.com/logo.png",
        "scope"                    => "read write profile",
        "contacts"                 => ["admin@example.com"],
        "tos_uri"                  => "https://example.com/tos",
        "policy_uri"               => "https://example.com/privacy",
      })

      response.status_code.should eq 201

      body = JSON.parse(response.body)
      body["client_id"].as_s.should_not be_empty
      body["client_name"].as_s.should eq "Full Metadata App"
      body["redirect_uris"].as_a.size.should eq 2
      body["token_endpoint_auth_method"].as_s.should eq "client_secret_basic"
      body["grant_types"].as_a.should contain("authorization_code")
      body["grant_types"].as_a.should contain("refresh_token")
      body["response_types"].as_a.should contain("code")
      body["scope"].as_s.should eq "read write profile"
    end

    it "returns client_id_issued_at timestamp" do
      response = register_client({
        "client_name"   => "Timestamp Test",
        "redirect_uris" => ["https://example.com/callback"],
      })

      response.status_code.should eq 201

      body = JSON.parse(response.body)
      body["client_id_issued_at"].as_i64.should be > 0
    end

    it "returns client_secret_expires_at as 0 for non-expiring secrets" do
      response = register_client({
        "client_name"   => "Non-expiring Secret",
        "redirect_uris" => ["https://example.com/callback"],
      })

      response.status_code.should eq 201

      body = JSON.parse(response.body)
      body["client_secret_expires_at"].as_i64.should eq 0
    end

    describe "validation" do
      it "returns 400 when redirect_uris is missing" do
        response = register_client({
          "client_name" => "Missing Redirect",
        })

        response.status_code.should eq 400

        body = JSON.parse(response.body)
        body["error"].as_s.should eq "invalid_client_metadata"
        body["error_description"].as_s.should contain("redirect_uris")
      end

      it "returns 400 when redirect_uris is empty" do
        response = register_client({
          "client_name"   => "Empty Redirect",
          "redirect_uris" => [] of String,
        })

        response.status_code.should eq 400

        body = JSON.parse(response.body)
        body["error"].as_s.should eq "invalid_client_metadata"
      end

      it "returns 400 for invalid redirect_uri scheme" do
        response = register_client({
          "client_name"   => "Invalid Scheme",
          "redirect_uris" => ["javascript:alert(1)"],
        })

        response.status_code.should eq 400

        body = JSON.parse(response.body)
        body["error"].as_s.should eq "invalid_redirect_uri"
      end

      it "returns 400 for redirect_uri with fragment" do
        response = register_client({
          "client_name"   => "Fragment URI",
          "redirect_uris" => ["https://example.com/callback#fragment"],
        })

        response.status_code.should eq 400

        body = JSON.parse(response.body)
        body["error"].as_s.should eq "invalid_redirect_uri"
      end

      it "returns 400 for unsupported grant_type" do
        response = register_client({
          "client_name"   => "Invalid Grant",
          "redirect_uris" => ["https://example.com/callback"],
          "grant_types"   => ["unsupported_grant"],
        })

        response.status_code.should eq 400

        body = JSON.parse(response.body)
        body["error"].as_s.should eq "invalid_client_metadata"
        body["error_description"].as_s.should contain("grant_types")
      end

      it "returns 400 for unsupported response_type" do
        response = register_client({
          "client_name"    => "Invalid Response",
          "redirect_uris"  => ["https://example.com/callback"],
          "response_types" => ["unsupported_response"],
        })

        response.status_code.should eq 400

        body = JSON.parse(response.body)
        body["error"].as_s.should eq "invalid_client_metadata"
      end
    end

    describe "public clients" do
      it "registers public client without client_secret" do
        response = register_client({
          "client_name"              => "Public App",
          "redirect_uris"            => ["https://example.com/callback"],
          "token_endpoint_auth_method" => "none",
        })

        response.status_code.should eq 201

        body = JSON.parse(response.body)
        body["client_id"].as_s.should_not be_empty
        body["token_endpoint_auth_method"].as_s.should eq "none"
        # Public clients should not receive a client_secret
        body["client_secret"]?.should be_nil
      end
    end

    describe "defaults" do
      it "defaults grant_types to authorization_code" do
        response = register_client({
          "client_name"   => "Default Grant",
          "redirect_uris" => ["https://example.com/callback"],
        })

        response.status_code.should eq 201

        body = JSON.parse(response.body)
        body["grant_types"].as_a.should contain("authorization_code")
      end

      it "defaults response_types to code" do
        response = register_client({
          "client_name"   => "Default Response",
          "redirect_uris" => ["https://example.com/callback"],
        })

        response.status_code.should eq 201

        body = JSON.parse(response.body)
        body["response_types"].as_a.should contain("code")
      end

      it "defaults token_endpoint_auth_method to client_secret_basic" do
        response = register_client({
          "client_name"   => "Default Auth",
          "redirect_uris" => ["https://example.com/callback"],
        })

        response.status_code.should eq 201

        body = JSON.parse(response.body)
        body["token_endpoint_auth_method"].as_s.should eq "client_secret_basic"
      end
    end
  end
end

# Helper to make registration requests
def register_client(metadata : Hash(String, String | Array(String)))
  http_client = HTTP::Client.new("localhost", 4000)
  headers = HTTP::Headers{
    "Content-Type" => "application/json",
    "Accept"       => "application/json",
  }

  http_client.post("/register", headers: headers, body: metadata.to_json)
end
