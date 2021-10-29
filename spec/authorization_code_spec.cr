require "./spec_helper"

describe Authority do
  username = Faker::Internet.email
  password = Faker::Internet.password
  create_owner(username, password)

  # describe "Authorization Code Flow" do
  #   state = Random::Secure.hex
  #   auth_url = OAUTH_CLIENT.get_authorize_uri(scope: "read", state: state)

  #   it "gets access token" do
  #     code, expected_state = AuthorizationCodeFlux.flow(auth_url, username, password)
  #     token = OAUTH_CLIENT.get_access_token_using_authorization_code(code)

  #     expected_state.should eq state
  #     token.should be_a OAuth2::AccessToken::Bearer
  #   end
  # end

  describe "PKCE Extension" do
    code_verifier = Faker::Internet.password(43, 128)
    state = Random::Secure.hex

    # describe "Method Plain" do
    #   code_challenge = code_verifier
    #   code_challenge_method = "plain"

    #   it "gets access token" do
    #   end
    # end

    describe "Method S256" do
      it "gets access token" do
        auth_url = prepare_code_challenge_url(code_verifier, state)
        code, expected_state = AuthorizationCodeFlux.flow(auth_url, username, password)

        token = OAUTH_CLIENT.get_access_token_using_authorization_code(code)

        expected_state.should eq state
        token.should be_a OAuth2::AccessToken::Bearer
      end
    end
  end
end
