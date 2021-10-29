require "./spec_helper"

describe Authority do
  describe "Password Flow" do
    username = Faker::Internet.email
    password = Faker::Internet.password

    create_owner(username, password)

    it "gets access token" do
      token = OAUTH_CLIENT.get_access_token_using_resource_owner_credentials(
        username: username, password: password, scope: "read"
      )
      token.should be_a OAuth2::AccessToken::Bearer
    end
  end
end
