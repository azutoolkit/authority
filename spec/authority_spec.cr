require "./spec_helper"

describe Authority do
  username = Faker::Internet.email
  password = Faker::Internet.password

  describe "Authorization Code Flow" do
    state = Random::Secure.hex
    auth_url = OAUTH_CLIENT.get_authorize_uri(scope: "read", state: state)

    clear_db

    create_owner(username, password)

    it "gets access token" do
      code, expected_state = AuthorizationCode.flow(auth_url, username, password)
      token = OAUTH_CLIENT.get_access_token_using_authorization_code(code)

      expected_state.should eq state
      token.should be_a OAuth2::AccessToken::Bearer
    end
  end

  describe "Client Credentials Flow" do
    it "gets access token" do
      token = OAUTH_CLIENT.get_access_token_using_client_credentials scope: "read"
      token.should be_a OAuth2::AccessToken::Bearer
    end
  end

  describe "Password Flow" do
    it "gets access token" do
      token = OAUTH_CLIENT.get_access_token_using_resource_owner_credentials(
        username: username, password: password, scope: "read"
      )
      token.should be_a OAuth2::AccessToken::Bearer
    end
  end

  describe "Refresh Token Flow" do
    it "gets access token" do
      refresh = OAUTH_CLIENT.get_access_token_using_client_credentials scope: "read"
      token = OAUTH_CLIENT.get_access_token_using_refresh_token refresh.refresh_token, scope: "read"
      token.should be_a OAuth2::AccessToken::Bearer
    end
  end

  describe "PKCE Extension" do
    code_verifier = Faker::Internet.password(43, 128)
    response_type = "code"
    state = Faker::Internet.password(32, 32)

    describe "Method Plain" do
      code_challenge = code_verifier
      code_challenge_method = "plain"

      it "gets access token" do
      end
    end

    describe "Method S256" do
      code_challenge_method = "S256"
      code_challenge = Digest::SHA256.base64digest(code_verifier)

      it "gets access token" do
      end
    end
  end

  describe "Token Introspection" do
  end
end
