require "./spec_helper"

describe Authority do
  describe "Client Credentials Flow" do
    it "gets access token" do
      token = OAUTH_CLIENT.get_access_token_using_client_credentials scope: "read"
      token.should be_a OAuth2::AccessToken::Bearer
    end
  end
end
