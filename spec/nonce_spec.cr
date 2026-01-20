require "./spec_helper"

describe "OpenID Connect Nonce Parameter" do
  password = Faker::Internet.password

  describe "Authorization Code with Nonce" do
    it "includes nonce in the authorization code JWT" do
      nonce = Random::Secure.hex(16)

      # Create authorization code with nonce
      code = Authly::Code.new(
        client_id: CLIENT_ID,
        scope: "openid profile",
        redirect_uri: REDIRECT_URI,
        challenge: "",
        method: "",
        user_id: "user-123",
        nonce: nonce
      )

      # Decode the JWT and verify nonce is present
      jwt = code.jwt
      payload, _ = Authly.jwt_decode(jwt)

      payload["nonce"].as_s.should eq nonce
    end

    it "handles empty nonce gracefully" do
      code = Authly::Code.new(
        client_id: CLIENT_ID,
        scope: "openid profile",
        redirect_uri: REDIRECT_URI,
        user_id: "user-123"
      )

      jwt = code.jwt
      payload, _ = Authly.jwt_decode(jwt)

      payload["nonce"].as_s.should eq ""
    end
  end

  describe "ID Token with Nonce" do
    it "includes nonce claim when provided in authorization request" do
      user = create_owner(password: password)
      nonce = Random::Secure.hex(16)

      # Get authorization code with nonce
      code, code_verifier, _ = prepare_code_challenge_url_with_nonce(
        user.username, password, "S256", "openid", nonce
      )

      # Exchange code for tokens
      response = create_token_request(code, code_verifier, "openid")
      token = OAuth2::AccessToken::Bearer.from_json(response.body)

      # Verify ID token contains nonce
      id_token_jwt = token.extra.not_nil!["id_token"].to_s
      id_token_jwt.should_not be_empty

      payload, _ = Authly.jwt_decode(id_token_jwt)
      payload["nonce"].as_s.should eq nonce
    end

    it "has empty nonce when not provided in authorization request" do
      user = create_owner(password: password)

      # Get authorization code without nonce
      code, code_verifier, _ = prepare_code_challenge_url(
        user.username, password, "S256", "openid"
      )

      # Exchange code for tokens
      response = create_token_request(code, code_verifier, "openid")
      token = OAuth2::AccessToken::Bearer.from_json(response.body)

      # Verify ID token exists
      id_token_jwt = token.extra.not_nil!["id_token"].to_s
      id_token_jwt.should_not be_empty

      payload, _ = Authly.jwt_decode(id_token_jwt)

      # Nonce should not be present when not provided
      payload["nonce"]?.should be_nil
    end
  end

  describe "Nonce Replay Prevention" do
    it "client can verify nonce matches the one sent" do
      user = create_owner(password: password)
      original_nonce = Random::Secure.hex(16)

      # Get tokens with nonce
      code, code_verifier, _ = prepare_code_challenge_url_with_nonce(
        user.username, password, "S256", "openid", original_nonce
      )

      response = create_token_request(code, code_verifier, "openid")
      token = OAuth2::AccessToken::Bearer.from_json(response.body)

      id_token_jwt = token.extra.not_nil!["id_token"].to_s
      payload, _ = Authly.jwt_decode(id_token_jwt)

      # Client-side verification: nonce in ID token must match original
      payload["nonce"].as_s.should eq original_nonce
    end

    it "different nonce values produce different ID tokens" do
      user = create_owner(password: password)
      nonce1 = Random::Secure.hex(16)
      nonce2 = Random::Secure.hex(16)

      # First request with nonce1
      code1, verifier1, _ = prepare_code_challenge_url_with_nonce(
        user.username, password, "S256", "openid", nonce1
      )
      response1 = create_token_request(code1, verifier1, "openid")
      token1 = OAuth2::AccessToken::Bearer.from_json(response1.body)
      id_token1 = token1.extra.not_nil!["id_token"].to_s
      payload1, _ = Authly.jwt_decode(id_token1)

      # Second request with nonce2
      code2, verifier2, _ = prepare_code_challenge_url_with_nonce(
        user.username, password, "S256", "openid", nonce2
      )
      response2 = create_token_request(code2, verifier2, "openid")
      token2 = OAuth2::AccessToken::Bearer.from_json(response2.body)
      id_token2 = token2.extra.not_nil!["id_token"].to_s
      payload2, _ = Authly.jwt_decode(id_token2)

      # Nonces should be different
      payload1["nonce"].as_s.should eq nonce1
      payload2["nonce"].as_s.should eq nonce2
      payload1["nonce"].as_s.should_not eq payload2["nonce"].as_s
    end
  end
end
