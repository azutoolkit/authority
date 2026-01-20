require "./spec_helper"

describe Authority::LogoutService do
  describe ".validate_request" do
    it "returns valid for request without id_token_hint" do
      result = Authority::LogoutService.validate_request(nil, nil, nil)
      result[:valid].should be_true
    end

    it "returns valid with post_logout_redirect_uri only" do
      # Without id_token_hint, we can't validate the redirect URI
      result = Authority::LogoutService.validate_request(nil, "https://app.example.com/logged-out", nil)
      result[:valid].should be_true
    end

    it "returns invalid for malformed id_token_hint" do
      result = Authority::LogoutService.validate_request("invalid-token", nil, nil)
      result[:valid].should be_false
      result[:error].should eq "invalid_request"
    end
  end

  describe ".build_redirect_url" do
    it "returns nil when no redirect_uri provided" do
      Authority::LogoutService.build_redirect_url(nil, nil).should be_nil
    end

    it "returns redirect_uri when provided" do
      url = Authority::LogoutService.build_redirect_url("https://app.example.com/logged-out", nil)
      url.should eq "https://app.example.com/logged-out"
    end

    it "appends state parameter when provided" do
      url = Authority::LogoutService.build_redirect_url("https://app.example.com/logged-out", "abc123")
      url.should eq "https://app.example.com/logged-out?state=abc123"
    end

    it "appends state to existing query string" do
      url = Authority::LogoutService.build_redirect_url("https://app.example.com/logged-out?foo=bar", "abc123")
      url.should eq "https://app.example.com/logged-out?foo=bar&state=abc123"
    end
  end

  describe ".extract_client_id_from_token" do
    it "returns nil for invalid token" do
      Authority::LogoutService.extract_client_id_from_token("invalid").should be_nil
    end

    it "returns nil for nil token" do
      Authority::LogoutService.extract_client_id_from_token(nil).should be_nil
    end
  end

  describe ".valid_post_logout_redirect?" do
    it "returns true for any URI when client_id is nil" do
      Authority::LogoutService.valid_post_logout_redirect?(nil, "https://any.example.com").should be_true
    end

    it "returns false for invalid URI format" do
      Authority::LogoutService.valid_post_logout_redirect?(CLIENT_ID, "not-a-uri").should be_false
    end

    it "returns false for URI with fragment" do
      Authority::LogoutService.valid_post_logout_redirect?(CLIENT_ID, "https://app.example.com#fragment").should be_false
    end
  end
end
