require "./spec_helper"

CLIENT_ID      = Faker::Internet.user_name
CLIENT_SECCRET = Faker::Internet.password(32, 32)
REDIRECT_URI   = "http://www.example.com/callback"
OAUTH_CLIENT   = OAuth2::Client.new(
  "localhost", CLIENT_ID, CLIENT_SECCRET, port: 4000, scheme: "http",
  redirect_uri: REDIRECT_URI, authorize_uri: "/authorize", token_uri: "/token")

describe Authority do
  username = Faker::Internet.email
  password = Faker::Internet.password
  create_owner(username, password)

  # describe "Authorization Code Flow" do
  #   state = Random::Secure.hex
  #   auth_url = OAUTH_CLIENT.get_authorize_uri(scope: "read", state: state)

  #   it "gets access token" do
  #     code, expected_state = AuthorizationCode.flow(auth_url, username, password)
  #     token = OAUTH_CLIENT.get_access_token_using_authorization_code(code)

  #     expected_state.should eq state
  #     token.should be_a OAuth2::AccessToken::Bearer
  #   end
  # end

  # describe "Client Credentials Flow" do
  #   it "gets access token" do
  #     token = OAUTH_CLIENT.get_access_token_using_client_credentials scope: "read"
  #     token.should be_a OAuth2::AccessToken::Bearer
  #   end
  # end

  # describe "Password Flow" do
  #   it "gets access token" do
  #     token = OAUTH_CLIENT.get_access_token_using_resource_owner_credentials(
  #       username: username, password: password, scope: "read"
  #     )
  #     token.should be_a OAuth2::AccessToken::Bearer
  #   end
  # end

  # describe "Refresh Token Flow" do
  #   it "gets access token" do
  #     refresh = OAUTH_CLIENT.get_access_token_using_client_credentials scope: "read"
  #     token = OAUTH_CLIENT.get_access_token_using_refresh_token refresh.refresh_token, scope: "read"
  #     token.should be_a OAuth2::AccessToken::Bearer
  #   end
  # end

  describe "PKCE Extension" do
    code_verifier = Faker::Internet.password(43, 128)
    response_type = "code"
    state = Faker::Internet.password(32, 32)

    # describe "Method Plain" do
    #   code_challenge = code_verifier
    #   code_challenge_method = "plain"

    #   it "gets access token" do
    #   end
    # end

    describe "Method S256" do
      code_challenge_method = "S256"
      code_challenge = Digest::SHA256.base64digest(code_verifier)
      state = Random::Secure.hex

      auth_url = OAUTH_CLIENT.get_authorize_uri(scope: "read", state: state) do |param|
        param.add "code_challenge", code_challenge
        param.add "code_challenge_method", code_challenge_method
      end

      it "gets access token" do
        create_owner(username, password)
        code, expected_state = AuthorizationCode.flow(auth_url, username, password)
        token = OAUTH_CLIENT.get_access_token_using_authorization_code(code)

        expected_state.should eq state
        token.should be_a OAuth2::AccessToken::Bearer
      end
    end
  end

  describe "Token Introspection" do
  end
end
