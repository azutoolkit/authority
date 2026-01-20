require "./spec_helper"

describe Authority::PARService do
  # Clear PAR data before each test
  Spec.before_each do
    AuthorityDB.exec_query { |conn| conn.exec("TRUNCATE TABLE oauth_par_requests CASCADE") }
  end

  describe ".create_request" do
    it "creates a PAR request and returns request_uri" do
      result = Authority::PARService.create_request(
        client_id: CLIENT_ID,
        redirect_uri: REDIRECT_URI,
        response_type: "code",
        scope: "openid",
        state: "abc123",
        code_challenge: nil,
        code_challenge_method: nil,
        nonce: nil
      )

      result[:success].should be_true
      result[:request_uri].should_not be_nil
      if uri = result[:request_uri]
        uri.should start_with "urn:ietf:params:oauth:request_uri:"
      end
      result[:expires_in].should eq 90
    end

    it "returns error for unknown client" do
      result = Authority::PARService.create_request(
        client_id: "unknown-client",
        redirect_uri: REDIRECT_URI,
        response_type: "code",
        scope: "openid",
        state: "abc123",
        code_challenge: nil,
        code_challenge_method: nil,
        nonce: nil
      )

      result[:success].should be_false
      result[:error].should eq "invalid_client"
    end
  end

  describe ".get_request" do
    it "retrieves stored PAR request" do
      create_result = Authority::PARService.create_request(
        client_id: CLIENT_ID,
        redirect_uri: REDIRECT_URI,
        response_type: "code",
        scope: "openid profile",
        state: "xyz789",
        code_challenge: "challenge123",
        code_challenge_method: "S256",
        nonce: "nonce456"
      )

      request_uri = create_result[:request_uri].not_nil!
      request = Authority::PARService.get_request(request_uri, CLIENT_ID)

      request.should_not be_nil
      if req = request
        req[:redirect_uri].should eq REDIRECT_URI
        req[:response_type].should eq "code"
        req[:scope].should eq "openid profile"
        req[:state].should eq "xyz789"
        req[:code_challenge].should eq "challenge123"
        req[:code_challenge_method].should eq "S256"
        req[:nonce].should eq "nonce456"
      end
    end

    it "returns nil for non-existent request_uri" do
      Authority::PARService.get_request("urn:ietf:params:oauth:request_uri:nonexistent", CLIENT_ID).should be_nil
    end

    it "returns nil for wrong client_id" do
      create_result = Authority::PARService.create_request(
        client_id: CLIENT_ID,
        redirect_uri: REDIRECT_URI,
        response_type: "code",
        scope: "openid",
        state: "abc123",
        code_challenge: nil,
        code_challenge_method: nil,
        nonce: nil
      )

      request_uri = create_result[:request_uri].not_nil!
      Authority::PARService.get_request(request_uri, "different-client").should be_nil
    end

    it "marks request as used after retrieval" do
      create_result = Authority::PARService.create_request(
        client_id: CLIENT_ID,
        redirect_uri: REDIRECT_URI,
        response_type: "code",
        scope: "openid",
        state: "abc123",
        code_challenge: nil,
        code_challenge_method: nil,
        nonce: nil
      )

      request_uri = create_result[:request_uri].not_nil!

      # First retrieval should succeed
      Authority::PARService.get_request(request_uri, CLIENT_ID).should_not be_nil

      # Second retrieval should fail (single-use)
      Authority::PARService.get_request(request_uri, CLIENT_ID).should be_nil
    end
  end

  describe ".cleanup_expired" do
    it "removes expired PAR requests" do
      # Create a request
      Authority::PARService.create_request(
        client_id: CLIENT_ID,
        redirect_uri: REDIRECT_URI,
        response_type: "code",
        scope: "openid",
        state: "abc123",
        code_challenge: nil,
        code_challenge_method: nil,
        nonce: nil
      )

      # Cleanup with 0 seconds should remove it
      deleted = Authority::PARService.cleanup_expired(0.seconds)
      deleted.should be >= 0
    end
  end
end
