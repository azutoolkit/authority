require "./spec_helper"

describe Authority do
  describe "Authorization Code Flow" do
    it "gets access token" do
      user = create_owner
      state = Random::Secure.hex
      auth_url = OAUTH_CLIENT.get_authorize_uri(scope: "read", state: state)
      code, expected_state = AuthorizationCodeFlux.flow(auth_url, user.username, user.password)

      token = OAUTH_CLIENT.get_access_token_using_authorization_code(code)

      expected_state.should eq state
      token.should be_a OAuth2::AccessToken::Bearer
    end
  end
end
