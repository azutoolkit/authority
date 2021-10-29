require "./spec_helper"

describe Authority do
  describe "Password Flow" do
    it "gets access token" do
      user = create_owner

      token = OAUTH_CLIENT.get_access_token_using_resource_owner_credentials(
        username: user.username, password: user.password, scope: "read"
      )

      token.should be_a OAuth2::AccessToken::Bearer
    end
  end
end
