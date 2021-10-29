require "./spec_helper"

describe Authority do
  describe "Refresh Token Flow" do
    it "gets access token" do
      refresh = OAUTH_CLIENT.get_access_token_using_client_credentials scope: "read"
      token = OAUTH_CLIENT.get_access_token_using_refresh_token refresh.refresh_token, scope: "read"
      token.should be_a OAuth2::AccessToken::Bearer
    end
  end

  describe "Create Token" do
    it "with code verifier" do
      http_client = OAUTH_CLIENT.http_client
      token_url = "/token"
      username = Faker::Internet.email
      password = Faker::Internet.password
      create_owner(username, password)
      code, code_verifier, expected_state = prepare_code_challenge_url(username, password)
      headers = HTTP::Headers{
        "Accept"        => "application/json",
        "Content-Type"  => "application/x-www-form-urlencoded",
        "Authorization" => "Basic #{Base64.strict_encode("#{CLIENT_ID}:#{CLIENT_SECRET}")}",
      }

      result = http_client.post(token_url, headers: headers, form: {
        "grant_type"    => "authorization_code",
        "redirect_uri"  => REDIRECT_URI,
        "code"          => code,
        "code_verifier" => code_verifier,
      })

      p result.body

      result.status_message.should eq "OK"
    end
  end

  describe "Inspect Token" do
  end
end
