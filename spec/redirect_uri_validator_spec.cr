require "./spec_helper"

describe Authority::RedirectURIValidator do
  # Test client has redirect_uri registered via spec_helper
  describe ".valid?" do
    it "returns true for exact match" do
      Authority::RedirectURIValidator.valid?(CLIENT_ID, REDIRECT_URI).should be_true
    end

    it "returns false for unregistered URI" do
      Authority::RedirectURIValidator.valid?(CLIENT_ID, "https://evil.com/callback").should be_false
    end

    it "returns false for path traversal attempt" do
      # Build a path traversal URI based on the registered one
      traversal_uri = REDIRECT_URI.sub(/\/[^\/]*$/, "/../other")
      Authority::RedirectURIValidator.valid?(CLIENT_ID, traversal_uri).should be_false
    end

    it "returns false for unknown client" do
      Authority::RedirectURIValidator.valid?("unknown-client-id", REDIRECT_URI).should be_false
    end

    it "returns false for empty redirect_uri" do
      Authority::RedirectURIValidator.valid?(CLIENT_ID, "").should be_false
    end

    it "is case-insensitive for scheme and host" do
      # Parse the URI and uppercase scheme/host
      uri = URI.parse(REDIRECT_URI)
      uppercase_uri = "#{uri.scheme.try(&.upcase)}://#{uri.host.try(&.upcase)}#{uri.path}"
      Authority::RedirectURIValidator.valid?(CLIENT_ID, uppercase_uri).should be_true
    end

    it "normalizes default port numbers (443 for https)" do
      uri = URI.parse(REDIRECT_URI)
      next unless uri.scheme == "https"
      explicit_port_uri = "#{uri.scheme}://#{uri.host}:443#{uri.path}"
      Authority::RedirectURIValidator.valid?(CLIENT_ID, explicit_port_uri).should be_true
    end

    it "normalizes default port numbers (80 for http)" do
      uri = URI.parse(REDIRECT_URI)
      next unless uri.scheme == "http"
      explicit_port_uri = "#{uri.scheme}://#{uri.host}:80#{uri.path}"
      Authority::RedirectURIValidator.valid?(CLIENT_ID, explicit_port_uri).should be_true
    end

    it "rejects fragment in redirect URI" do
      uri_with_fragment = "#{REDIRECT_URI}#fragment"
      Authority::RedirectURIValidator.valid?(CLIENT_ID, uri_with_fragment).should be_false
    end

    it "preserves query parameters in comparison" do
      # If registered URI has no query, URI with query should fail
      uri_with_query = "#{REDIRECT_URI}?extra=param"
      # This should fail because registered URI doesn't have query params
      Authority::RedirectURIValidator.valid?(CLIENT_ID, uri_with_query).should be_false
    end
  end
end
