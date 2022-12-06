require "./spec_helper"

describe "TokenSpec" do
  password = Faker::Internet.password

  describe "token instropection" do
    client = OAUTH_CLIENT.http_client
    client.basic_auth(CLIENT_ID, CLIENT_SECRET)
    scope = "any"

    it "return false fo inactive token" do
      expires = 1.minute.ago.to_unix
      jwt_token = Authly.jwt_encode({"exp" => expires, "scope" => scope})

      response = client.post("/token-info", form: {token: jwt_token})
      token_info = JSON.parse(response.body)

      token_info["active"].as_bool.should be_falsey
      token_info["exp"].should eq ""
      token_info["scope"].should eq ""
    end

    it "returns true for a active token" do
      expires = 1.minute.from_now.to_unix
      jwt_token = Authly.jwt_encode({"exp" => 1.minute.from_now.to_unix, "scope" => scope})

      response = client.post("/token-info", form: {token: jwt_token})
      token_info = JSON.parse(response.body)

      token_info["active"].as_bool.should be_truthy
      token_info["exp"].should eq expires.to_s
      token_info["scope"].should eq scope
    end
  end

  describe "OpenID" do
    it "returns id_token" do
      user = create_owner(password: password)

      scope = "openid read"
      code, code_verifier, _ = prepare_code_challenge_url(
        user.username, password, "S256", scope)

      response = create_token_request(code, code_verifier, scope)

      token = OAuth2::AccessToken::Bearer.from_json(response.body)

      id_token = token.extra.not_nil!["id_token"]
      id_token.should_not be_nil
    end
  end

  describe "Refresh Token Flow" do
    it "gets access token" do
      refresh = OAUTH_CLIENT.get_access_token_using_client_credentials scope: "read"
      token = OAUTH_CLIENT.get_access_token_using_refresh_token refresh.refresh_token, scope: "read"
      token.should be_a OAuth2::AccessToken::Bearer
    end
  end

  describe "Create Token" do
    describe "Method S256" do
      it "creates access token" do
        user = create_owner(password: password)
        code, code_verifier, _ = prepare_code_challenge_url(
          user.username, password, "S256")

        response = create_token_request(code, code_verifier)
        token = OAuth2::AccessToken::Bearer.from_json(response.body)

        response.status_message.should eq "Created"
        token.should be_a OAuth2::AccessToken::Bearer
      end
    end

    describe "Method PLAIN" do
      it "creates access token" do
        user = create_owner(password: password)
        code, code_verifier, _ = prepare_code_challenge_url(
          user.username, password, "plain")

        response = create_token_request(code, code_verifier)
        token = OAuth2::AccessToken::Bearer.from_json(response.body)

        response.status_message.should eq "Created"
        token.should be_a OAuth2::AccessToken::Bearer
      end
    end
  end

  describe "Inspect Token" do
  end
end
