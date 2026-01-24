require "./spec_helper"

describe Authority::JARMService do
  describe ".create_response" do
    it "creates a signed JWT response with code and state" do
      result = Authority::JARMService.create_response(
        client_id: CLIENT_ID,
        redirect_uri: REDIRECT_URI,
        code: "auth-code-123",
        state: "state-xyz",
        error: nil,
        error_description: nil
      )

      result[:success].should be_true
      result[:jwt].should_not be_nil

      # JWT should have 3 parts separated by dots
      result[:jwt].should_not be_nil
      result[:jwt].try(&.split('.').size.should(eq(3)))
    end

    it "creates a signed JWT response with error" do
      result = Authority::JARMService.create_response(
        client_id: CLIENT_ID,
        redirect_uri: REDIRECT_URI,
        code: nil,
        state: "state-xyz",
        error: "access_denied",
        error_description: "User denied the request"
      )

      result[:success].should be_true
      result[:jwt].should_not be_nil
    end

    it "includes required JARM claims in payload" do
      result = Authority::JARMService.create_response(
        client_id: CLIENT_ID,
        redirect_uri: REDIRECT_URI,
        code: "auth-code-123",
        state: "state-xyz",
        error: nil,
        error_description: nil
      )

      result[:jwt].should_not be_nil
      if jwt = result[:jwt]
        payload = Authority::JARMService.decode_payload(jwt)

        payload.should_not be_nil
        if claims = payload
          claims["iss"]?.should_not be_nil # Issuer
          claims["aud"]?.should_not be_nil # Audience (client_id)
          claims["exp"]?.should_not be_nil # Expiration
          claims["code"]?.should eq "auth-code-123"
          claims["state"]?.should eq "state-xyz"
        end
      end
    end
  end

  describe ".build_redirect_url" do
    it "builds redirect URL with JWT in query for query.jwt mode" do
      jwt = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJjb2RlIjoiYWJjMTIzIn0.signature"
      url = Authority::JARMService.build_redirect_url(
        redirect_uri: "https://app.example.com/callback",
        jwt: jwt,
        response_mode: "query.jwt"
      )

      url.should contain "response="
      url.should start_with "https://app.example.com/callback?"
    end

    it "builds redirect URL with JWT in fragment for fragment.jwt mode" do
      jwt = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJjb2RlIjoiYWJjMTIzIn0.signature"
      url = Authority::JARMService.build_redirect_url(
        redirect_uri: "https://app.example.com/callback",
        jwt: jwt,
        response_mode: "fragment.jwt"
      )

      url.should contain "#response="
    end

    it "defaults to query.jwt mode when mode is 'jwt'" do
      jwt = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJjb2RlIjoiYWJjMTIzIn0.signature"
      url = Authority::JARMService.build_redirect_url(
        redirect_uri: "https://app.example.com/callback",
        jwt: jwt,
        response_mode: "jwt"
      )

      url.should contain "?response="
    end
  end

  describe ".supported_response_mode?" do
    it "returns true for jwt" do
      Authority::JARMService.supported_response_mode?("jwt").should be_true
    end

    it "returns true for query.jwt" do
      Authority::JARMService.supported_response_mode?("query.jwt").should be_true
    end

    it "returns true for fragment.jwt" do
      Authority::JARMService.supported_response_mode?("fragment.jwt").should be_true
    end

    it "returns true for form_post.jwt" do
      Authority::JARMService.supported_response_mode?("form_post.jwt").should be_true
    end

    it "returns false for unsupported modes" do
      Authority::JARMService.supported_response_mode?("invalid").should be_false
      Authority::JARMService.supported_response_mode?("query").should be_false
    end
  end

  describe ".decode_payload" do
    it "decodes a valid JWT payload" do
      result = Authority::JARMService.create_response(
        client_id: CLIENT_ID,
        redirect_uri: REDIRECT_URI,
        code: "test-code",
        state: "test-state",
        error: nil,
        error_description: nil
      )

      result[:jwt].should_not be_nil
      if jwt = result[:jwt]
        payload = Authority::JARMService.decode_payload(jwt)

        payload.should_not be_nil
        if claims = payload
          claims["code"]?.should eq "test-code"
        end
      end
    end

    it "returns nil for invalid JWT" do
      Authority::JARMService.decode_payload("invalid-jwt").should be_nil
    end
  end
end
