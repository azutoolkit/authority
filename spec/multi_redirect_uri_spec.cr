require "./spec_helper"

describe "Multi-Redirect URI Support" do
  describe Authority::RedirectURIService do
    describe ".valid?" do
      it "validates against primary redirect_uri" do
        Authority::RedirectURIService.valid?(CLIENT_ID, REDIRECT_URI).should be_true
      end

      it "returns false for unregistered URI" do
        Authority::RedirectURIService.valid?(CLIENT_ID, "https://evil.com/callback").should be_false
      end

      it "returns false for unknown client" do
        Authority::RedirectURIService.valid?("unknown-client", REDIRECT_URI).should be_false
      end
    end

    describe ".get_redirect_uris" do
      it "returns the registered redirect URI" do
        uris = Authority::RedirectURIService.get_redirect_uris(CLIENT_ID)
        uris.should_not be_nil
        if uris_arr = uris
          uris_arr.should contain REDIRECT_URI
        end
      end

      it "returns nil for unknown client" do
        Authority::RedirectURIService.get_redirect_uris("unknown-client").should be_nil
      end
    end
  end

  describe "with multiple redirect URIs" do
    # Test with a client that has multiple redirect URIs
    before_each do
      # Add additional redirect URI to test client
      if client = Authority::Client.find_by(client_id: CLIENT_ID)
        client.redirect_uris = "#{REDIRECT_URI},https://app.example.com/callback2"
        client.update!
      end
    end

    after_each do
      # Reset to single URI
      if client = Authority::Client.find_by(client_id: CLIENT_ID)
        client.redirect_uris = REDIRECT_URI
        client.update!
      end
    end

    it "validates primary redirect URI" do
      Authority::RedirectURIService.valid?(CLIENT_ID, REDIRECT_URI).should be_true
    end

    it "validates secondary redirect URI" do
      Authority::RedirectURIService.valid?(CLIENT_ID, "https://app.example.com/callback2").should be_true
    end

    it "rejects unregistered URI" do
      Authority::RedirectURIService.valid?(CLIENT_ID, "https://other.com/callback").should be_false
    end

    it "returns all registered URIs" do
      uris = Authority::RedirectURIService.get_redirect_uris(CLIENT_ID)
      uris.should_not be_nil
      if uris_arr = uris
        uris_arr.size.should eq 2
      end
    end
  end
end
